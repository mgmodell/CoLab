# frozen_string_literal: true

class ProjectsController < ApplicationController
  include PermissionsCheck
  include LtiGradable

  before_action :set_project, only: %i[show edit update destroy activate
                                       rescore_group rescore_groups suggest_groups]
  before_action :check_editor, except: %i[rescore_group rescore_groups
                                          show index get_groups
                                          set_groups]
  before_action :check_viewer, only: %i[show index]

  def show
    respond_to do | format |
      format.json do
        course_hash = {
          id: @project.course_id,
          name: @project.course_name,
          timezone: ActiveSupport::TimeZone.new( @project.course_timezone ).tzinfo.name
        }
        response = {
          project: @project.as_json(
            only: %i[ id name description active start_date end_date
                      start_dow end_dow factor_pack_id style_id ]
          ),
          course: course_hash,
          factorPacks: FactorPack.all.as_json(
            only: :id, methods: :name
          ),
          styles: Style.all.as_json(
            only: :id, methods: :name
          ),
          messages: {
            status: params[:notice]
          }
        }
        render json: response
      end
    end
  end

  def edit; end

  def index
    @projects = []
    if current_user.is_admin?
      @projects = Project.all
    else
      rosters = current_user.rosters.instructor
      rosters.each do | roster |
        @projects.concat roster.course.projects.to_a
      end
    end
  end

  def create
    @project = Project.new( project_params )
    if @project.save
      respond_to do | format |
        format.json do
          response = {
            project: @project.as_json(
              only: %i[ id name description active start_date end_date
                        start_dow end_dow factor_pack_id style_id ]
            ),
            course: @project.course.as_json(
              only: %i[id name timezone]
            ),
            messages: {
              status: t( 'projects.create_success' )
            }
          }
          render json: response
        end
      end
    else
      logger.debug @project.errors.full_messages unless @project.errors.empty?
      respond_to do | format |
        format.json do
          render json: { messages: @project.errors }
        end
      end
    end
  end

  def update
    if @project.update( project_params )
      respond_to do | format |
        format.json do
          response = {
            project: @project.as_json(
              only: %i[ id name description active start_date end_date
                        start_dow end_dow factor_pack_id style_id ]
            ),
            course: @project.course.as_json(
              only: %i[id name timezone]
            ),
            messages: {
              status: if @project.active
                        t( 'projects.update_success' )
                      else
                        t( 'projects.update_success_inactive' )
                      end
            }
          }
          render json: response
        end
      end
    else
      logger.debug @project.errors.full_messages
      respond_to do | format |
        format.json do
          render json: { messages: @project.errors }
        end
      end
    end
  end

  def destroy
    @course = @project.course
    if @project.has_student_data?
      @project.update( active: false, deleted: true )
      msg = t( 'projects.soft_delete_success' )
    else
      @project.destroy
      msg = t( 'projects.destroy_success' )
    end
    respond_to do | format |
      format.html { redirect_to @course, notice: msg }
      format.json { render json: { message: msg } }
    end
  end

  def set_groups
    project = Project.includes( :groups, course: { rosters: :user } )
                     .find_by( id: params[:id] )

    group_hash = {}
    params[:groups].each_value do | g |
      group = nil
      group_id = g[:id].to_i
      if group_id.positive?
        group = project.groups.find_by id: group_id
        group.name = g[:name]
      else
        group = project.groups.build( name: g[:name] )
      end
      group.users = []
      group_hash[group_id] = group
    end
    params[:students].each_value do | s |
      student = project.rosters.find_by( user_id: s[:id] ).user
      group = group_hash[s[:group_id].to_i]
      group.users << student unless group.nil?
    end

    begin
      ActiveRecord::Base.transaction do
        group_hash.each_value do | group |
          group.calc_diversity_score
          group.save!
        end
        current_group_ids = group_hash.values.map( &:id ).compact
        groups_to_remove = Group.where( project: ).where.not( id: current_group_ids )
        groups_to_remove.destroy_all
      end
    rescue StandardError
      # Post back a JSON error
      get_groups_helper project:, message: t( 'projects.group_save_failure' )
    else
      project.groups.reset
      get_groups_helper project:, message: t( 'projects.group_save_success' )
    end
  end

  def get_groups
    project = Project.includes( rosters: { user: :emails }, groups: :users )
                     .joins( rosters: :user )
                     .left_outer_joins( groups: :users )
                     .find_by( id: params[:id] )

    get_groups_helper project:
  end

  # Builds a recommendation preview for the Groups tab without persisting it.
  #
  # This controller action is the bridge between the course roster and
  # Group.suggest_optimal_groups. It returns the suggested groups, preview-only
  # student assignments, and aggregate metrics that the React UI shows before
  # the instructor accepts or rejects the proposal.
  def suggest_groups
    students = @project.rosters.enrolled.includes(
      user: [
        :emails, :gender, :primary_language, :cip_code,
        { home_state: :home_country }, { reactions: :narrative }
      ]
    ).map( &:user )
    suggestion = Group.suggest_optimal_groups(
      users: students,
      target_group_size: params[:target_group_size],
      target_group_count: params[:target_group_count]
    )
    students_payload = build_students_payload @project
    suggested_students_payload = students_payload.deep_dup
    groups_payload = build_suggested_groups_payload( suggestion, suggested_students_payload )

    render json: {
      groups: groups_payload,
      students: suggested_students_payload,
      summary: {
        diversity_score_standard_deviation: suggestion[:diversity_score_standard_deviation],
        average_diversity_score: suggestion[:average_diversity_score],
        average_faultline_strength: suggestion[:average_faultline_strength],
        max_faultline_strength: suggestion[:max_faultline_strength]
      }
    }
  end

  def get_groups_helper( project:, message: nil )
    students = build_students_payload project
    groups = build_groups_payload( project, students )

    respond_to do | format |
      format.json do
        render json: {
          message:,
          groups:,
          students:
        }
      end
    end
  end

  def remove_group
    group = Group.find_by( id: params[:group_id] )
    group&.delete
    redirect_to @project
  end

  def add_group
    @project = Project.find( params[:project_id] )
    Group.create( name: params[:group_name], project: @project )

    redirect_to @project, notice: t( 'projects.group_create_success' )
  end

  def rescore_group
    group = @project.groups.find_by( id: params[:group_id] )
    if group.present?
      group.calc_diversity_score
      group.save
      logger.debug group.errors.full_messages unless group.errors.empty?

      respond_to do | format |
        format.json do
          get_groups
        end
      end
    else
      redirect_to @project, notice: t( 'projects.wrong_group' )
    end
  end

  def rescore_groups
    @project.groups.each do | group |
      group.calc_diversity_score
      group.save
      logger.debug group.errors.full_messages unless group.errors.empty?
    end

    respond_to do | format |
      format.json do
        get_groups
      end
    end
  end

  def activate
    if current_user.is_admin? ||
       'instructor' == @project.course.get_user_role( current_user )
      @project.active = true
      @project.save
      logger.debug @project.errors.full_messages unless @project.errors.empty?
    end
    render :show
  end

  private

  # Serializes enrolled roster members for the groups-management JSON payloads.
  def build_students_payload( project )
    students = {}
    project.rosters.enrolled.each do | roster |
      student = roster.user
      students[ student.id ] = {
        id: student.id,
        first_name: student.first_name,
        last_name: student.last_name,
        email: student.email
      }
    end
    students
  end

  # Serializes persisted project groups and annotates the passed-in students hash
  # with each member's saved group assignment.
  def build_groups_payload( project, students )
    groups = {}
    project.groups.each do | group |
      groups[group.id] = {
        id: group.id,
        name: group.name,
        diversity: group.diversity_score,
        faultline: group.calc_faultline_strength,
        member_count: group.users.count
      }
      group.users.each do | user |
        students[user.id][ :group_id ] = group.id
      end
    end
    groups
  end

  # Serializes a recommendation preview and annotates the passed-in students hash
  # with preview-only suggested group assignments.
  #
  # The returned structure mirrors build_groups_payload so the UI can preview a
  # recommendation and later submit it through the existing set_groups action.
  def build_suggested_groups_payload( suggestion, students )
    groups = {}
    suggestion.fetch( :groups, [] ).each_with_index do | suggested_group, index |
      group_id = -( index + 1 )
      groups[group_id] = {
        id: group_id,
        name: suggested_group[:name],
        diversity: suggested_group[:diversity_score],
        faultline: suggested_group[:faultline_strength],
        member_count: suggested_group[:users].count
      }
      suggested_group[:users].each do | user |
        students[user.id][ :group_id ] = group_id
      end
    end
    groups
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    if params[:id].blank? || 'new' == params[:id]
      course = Course.find( params[:course_id] )
      p_test = course.projects.new
      p_test.start_date = course.start_date
      p_test.end_date = course.end_date
    else
      p_test = Project.find( params[:id] )
    end

    if current_user.is_admin?
      @project = p_test
    elsif p_test.course.rosters.instructor.where( user: current_user ).nil?
      @course = @project.course
      redirect_to @course if @project.nil?
    else
      @project = p_test
    end
  end

  def project_params
    params.require( :project ).permit( :course_id, :name, :description, :start_date,
                                       :end_date, :start_dow, :end_dow, :active, :factor_pack_id,
                                       :style_id, groups: [:name] )
  end

  def lti_resource
    Project.find( params[:id] )
  end

  def grade_scores_for( project )
    project.groups.includes( :users ).flat_map do | group |
      group.users.map do | user |
        score = project.get_performance( user ).to_f
        { user_id: user.id.to_s, score_given: score, score_maximum: 100 }
      end
    end
  end
end
