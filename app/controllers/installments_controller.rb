# frozen_string_literal: true

class InstallmentsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[demo_complete demo_update]
  before_action :demo_user, only: %i[demo_complete]

  include Demoable

  def check_student( project: )
    status = nil
    error_type = :not_enrolled
    error = true
    error_data = {}

    # SQL Optimization: Use plucked tuples/ids for fast membership checks instead of loading full ActiveRecord objects
    instructor_user_ids = project.course.rosters.instructor.pluck(:user_id)
    enrolled_student_user_ids = project.course.rosters.enrolled_student.pluck(:user_id)

    if instructor_user_ids.include?( current_user.id )
      status = t( 'installments.error_instructor' )
      error_data = { project_id: project.id, course_id: project.course.id }
      error_type = :instructor
    elsif enrolled_student_user_ids.exclude?( current_user.id )
      status = t( 'installments.error_student' )
      error_type = :not_enrolled
    else
      active_assessment = project.assessments.active_at( Time.current ).first
      if active_assessment.nil?
        status = t( 'installments.error_no_active_assessment' )
        error_type = :no_active_assessment
        assessment = project.assessments.last
        if assessment
          error_data = {
            close_date: assessment.end_date,
            next_date: assessment.next_deadline,
            project_name: project.name
          }
        end
      else
        error = false
      end
    end

    if error
      render json: {
        messages: {
          error: error,
          error_type: error_type,
          error_data: error_data,
          status: status
        }
      }
    end

    !error
  end

  def submit_installment
    cur_date = Time.current
    project = Project.includes(course: :rosters).find( params[:project_id] )
    return unless check_student( project: project )

    assessment = project.assessments.active_at( cur_date ).first
    consent_log = project.course.get_consent_log( user: current_user )

    if consent_log.present? && !consent_log.presented?
      redirect_to edit_consent_log_path( consent_form_id: consent_log.consent_form_id )
      return
    end

    group = assessment.group_for_user( current_user )
    @factors = project.factors.to_a
    @installment = Installment.includes( values: %i[factor user], assessment: :project )
                              .find_by( assessment: assessment, user: current_user, group: group )

    if @installment.nil?
      @installment = Installment.new(
        assessment: assessment,
        user: current_user,
        inst_date: Time.current.in_time_zone( project.course_timezone ),
        group: group
      )

      group_users = group.users.to_a
      cell_value = Installment::TOTAL_VAL / group_users.size

      group_users.each do | u |
        @factors.each do | b |
          @installment.values.build( factor: b, user: u, value: cell_value )
        end
      end
    end

    submit_helper( factors: @factors, group: group, installment: @installment )
  end

  def submit_helper( factors:, group:, installment: )
    group_users = group.users.to_a
    values_json = installment.values.map do | v |
      { id: v.id, factor_id: v.factor_id, user_id: v.user_id, value: v.value }
    end

    render json: {
      factors: factors.index_by( &:id ).transform_values do | factor |
        { id: factor.id, name: factor.name, description: factor.description }
      end,
      group: {
        id: group.id,
        name: group.name,
        users: group_users.index_by( &:id ).transform_values do | member |
          { id: member.id, name: member.informal_name( false ) }
        end
      },
      installment: {
        id: installment.id,
        assessment_id: installment.assessment_id,
        group_id: installment.group_id,
        inst_date: installment.inst_date,
        values: values_json,
        project: {
          name: installment.assessment.project.name,
          description: installment.assessment.project.description
        }
      },
      sliderSum: Installment::TOTAL_VAL,
      messages: {
        error: false,
        error_type: nil,
        status: t( 'installments.success' )
      }
    }
  end

  def create
    ActiveRecord::Base.transaction do
      installment_hash = params[:installment]
      installment = Installment.create!(
        assessment_id: installment_hash[:assessment_id],
        group_id: installment_hash[:group_id],
        user: current_user,
        inst_date: installment_hash[:inst_date],
        comments: installment_hash[:comments]
      )

      now = Time.current
      values_payload = []

      params[:contributions].each_value do | contribution |
        contribution.each do | value |
          values_payload << {
            installment_id: installment.id,
            user_id: value[:userId],
            factor_id: value[:factorId],
            value: value[:value],
            created_at: now,
            updated_at: now
          }
        end
      end

      # Safe because there are no validations
      Value.insert_all!( values_payload ) if values_payload.any?

      installment.reload
      submit_helper(
        factors: installment.assessment.project.factors,
        group: installment.group,
        installment: installment
      )
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::StatementInvalid => e
    render json: {
      messages: {
        error: true,
        error_type: :installment_invalid,
        status: e.message
      },
      error: true
    }
  end

  def update
    id = params[:id].to_i

    ActiveRecord::Base.transaction do
      installment = Installment.includes( :values ).find_by( id: id, user: current_user )

      if installment.nil?
        render json: {
          messages: {
            error: true,
            error_type: :installment_not_found,
            status: t( 'installments.not_found' )
          },
          error: true
        }
        return
      end

      installment.update!( comments: params[:installment][:comments] )

      value_hash = installment.values.index_by( &:id )
      now = Time.current
      upsert_payload = []

      params[:contributions].each do | contribution |
        existing_val = value_hash[contribution[:id]]
        next unless existing_val

        upsert_payload << {
          id: existing_val.id,
          installment_id: installment.id,
          user_id: existing_val.user_id,
          factor_id: existing_val.factor_id,
          value: contribution[:value],
          created_at: existing_val.created_at,
          updated_at: now
        }
      end

      # Safe because there are no validations
      Value.upsert_all( upsert_payload ) if upsert_payload.any?

      render json: {
        messages: {
          error: false,
          status: t( 'installments.success' )
        },
        installment: {
          id: id,
          assessment_id: params[:assessment_id],
          group_id: params[:group_id],
          values: params[:contributions]
        }
      }
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { messages: e.message, error: true }
  end

  def demo_update
    result = {
      messages: {
        error: false,
        error_type: nil,
        status: t( 'installments.demo_success' )
      },
      installment: {
        id: -42,
        assessment_id: params[:project_id],
        group_id: params[:group_id],
        values: params[:contributions].values.flatten.map do | item |
          {
            id: item[:id],
            user_id: item[:userId],
            factor_id: item[:factorId],
            name: item[:name],
            value: item[:value]
          }
        end
      }
    }
    render json: result
  end

  def demo_complete
    @project = get_demo_project
    @group = get_demo_group
    @installment = get_demo_installment
    @installment.group = @group

    @factors = @project.factor_pack
    @members = @group.users.to_a

    cell_value = Installment::TOTAL_VAL / @members.size
    @members.each do | u |
      @factors.each do | b |
        @installment.values_build( factor: b, user: u, value: cell_value )
      end
    end

    submit_helper( factors: @factors, group: @group, installment: @installment )
  end
end