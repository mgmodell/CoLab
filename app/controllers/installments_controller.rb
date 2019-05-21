# frozen_string_literal: true

class InstallmentsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[demo_complete]
  before_action :demo_user, only: %i[demo_complete]

  include Demoable

  def submit_installment
    @assessment = Assessment.find( params[ :assessment_id ] )
    @title = t 'installments.title'
    @project = @assessment.project
    consent_log = @project.course.get_consent_log user: @current_user

    if consent_log.present?
      redirect_to edit_consent_log_path( consent_form_id: consent_log.consent_form_id )
    else
      @group = @assessment.group_for_user current_user
      @members = @group.users
      @factors = @project.factors
      @installment = Installment.includes( values: %i[factor user], assessment: :project)
                                .where( assessment: @assessment,
                                        user: current_user,
                                        group: @group ).first
      if @installment.nil?
        @installment = Installment.new(id: 0,
                                       assessment: @assessment,
                                       user: current_user,
                                       inst_date: DateTime.current.in_time_zone(@project.course.timezone),
                                       group: @group)

        cell_value = Installment::TOTAL_VAL / @members.size
        @members.each do |u|
          @factors.each do |b|
            @installment.values.build(factor: b, user: u, value: cell_value)
          end
        end
      end
      @project_name = @project.name

      render @project.style.filename
    end

  end

  def update
    @title = t 'installments.title'
    id = params[:id].to_i
    if 0 > id
      flash[:notice] = t 'installments.demo_success'
      redirect_to root_url
    elsif id > 0 
      @installment = Installment.find( id )
      if @installment.update_attributes(i_params)
        notice = t('installments.success')
        redirect_to root_url, notice: notice
      else
        logger.debug @installment.errors.full_messages unless @installment.errors.empty?
        @group = Group.find(@installment.group)
        @project = @installment.assessment.project
        @factors = @installment.assessment.project.factors
        @project_name = @installment.assessment.project.name
        @members = @group.users
        render @project.style.filename
      end
    else
      @installment = Installment.new(i_params)
      @installment.id = nil
      found = false
      @installment.group.users.each do |user|
        found = true if current_user == user
      end

      if !found
        redirect_to root_url error: (t 'installments.err_not_member')
      elsif @installment.save
        project = @installment.assessment.project
        flash[:notice] = t 'installments.success'
        redirect_to root_url
      else
        @factors = @installment.assessment.project.factors
        @project_name = @installment.assessment.project.name
        @group = @installment.group

        @members = @installment.values_by_user.keys
        if @installment.errors[:base].any?
          flash[:error] = @installment.errors[:base][0]
          redirect_to root_url
        else
          flash[:error] = t 'installments.err_unknown'
          render @installment.assessment.project.style.filename
        end
      end
    end
  end

  def demo_complete
    @title = t 'demo_title', orig: t('installments.title')
    @project = get_demo_project
    @group = get_demo_group

    @installment = Installment.new(id: -42, user_id: -1, assessment_id: -1,
                                   group_id: @group.id)
    @factors = @project.factor_pack
    @members = @group.users

    cell_value = Installment::TOTAL_VAL / @members.size
    @members.each do |_u|
      @factors.each do |b|
        @installment.values.build(factor: b, user: _u, value: cell_value)
      end
    end

    render @project.style.filename
  end

  private

  def i_params
    params.require(:installment).permit(:inst_date, :comments, :group_id, :user_id, :assessment_id, :group_id,
                                        values_attributes: %i[factor_id user_id value])
  end
end
