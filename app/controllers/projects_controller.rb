# frozen_string_literal: true

class ProjectsController < ApplicationController
  include PermissionsCheck

  before_action :set_project, only: %i[show new edit update destroy activate
                                       rescore_group rescore_groups]
  before_action :check_editor, except: %i[next diagnose react
                                          rescore_group rescore_groups
                                          show index get_groups
                                          set_groups]
  before_action :check_viewer, only: %i[show index]

  def show
    @title = t('.title')
    respond_to do |format|
      format.html { render :show }
      format.json do
        course_hash = {
          id: @project.course_id,
          name: @project.course.name,
          timezone: ActiveSupport::TimeZone.new(@project.course.timezone).tzinfo.name
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

  def edit
    @title = t('.title')
  end

  def index
    @title = t('.title')
    @projects = []
    if current_user.is_admin?
      @projects = Project.all
    else
      rosters = current_user.rosters.instructor
      rosters.each do |roster|
        @projects.concat roster.course.projects.to_a
      end
    end
  end

  def create
    @title = t('.title')
    @project = Project.new(project_params)
    if @project.save
      respond_to do |format|
        format.html do
          notice = if @project.active
                     t('projects.create_success')
                   else
                     t('projects.create_success_inactive')
                   end
          redirect_to project_path(@project,
                                   notice:,
                                   format: params[:format])
        end
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
              status: t('projects.create_success')
            }
          }
          render json: response
        end
      end
    else
      logger.debug @project.errors.full_messages unless @project.errors.empty?
      respond_to do |format|
        format.html do
          render :new
        end
        format.json do
          render json: { messages: @project.errors }
        end
      end
    end
  end

  def update
    @title = t('projects.edit.title')
    if @project.update(project_params)
      respond_to do |format|
        format.html do
          notice = if @project.active
                     t('projects.update_success')
                   else
                     t('projects.update_success_inactive')
                   end
          redirect_to @project, notice:
        end
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
                        t('projects.update_success')
                      else
                        t('projects.update_success_inactive')
                      end
            }
          }
          render json: response
        end
      end
    else
      logger.debug @project.errors.full_messages
      respond_to do |format|
        format.html do
          render :edit
        end
        format.json do
          render json: { messages: @project.errors }
        end
      end
    end
  end

  def destroy
    @course = @project.course
    @project.destroy
    redirect_to @course, notice: t('projects.destroy_success')
  end

  def set_groups
    project = Project.includes(:groups, course: { rosters: :user })
                     .find_by(id: params[:id])

    group_hash = {}
    params[:groups].each_value do |g|
      group = nil
      if (g[:id]).positive?
        group = project.groups.find_by id: g[:id]
        group.name = g[:name]
      else
        group = project.groups.build(name: g[:name])
      end
      group.users = []
      group_hash[g[:id]] = group
    end
    params[:students].each_value do |s|
      student = project.rosters.find_by(user_id: s[:id]).user
      group = group_hash[s[:group_id]]
      group.users << student unless group.nil?
    end

    begin
      ActiveRecord::Base.transaction do
        group_hash.values.each(&:save!)
      end
    rescue StandardError => e
      # Post back a JSON error
      get_groups_helper project:, message: t('projects.group_save_failure')
    else
      get_groups_helper project:, message: t('projects.group_save_success')
    end
  end

  def get_groups
    project = Project.includes(rosters: { user: :emails }, groups: :users)
                     .joins(rosters: :user)
                     .left_outer_joins(groups: :users)
                     .find_by(id: params[:id])

    get_groups_helper project:
  end

  def get_groups_helper(project:, message: nil)
    students = {}
    project.rosters.enrolled.each do |roster|
      student = roster.user
      students[ student.id ] = {
        id: student.id,
        first_name: student.first_name,
        last_name: student.last_name,
        email: student.email
      }
    end

    groups = {}
    project.groups.each do |group|
      groups[group.id] = {
        id: group.id,
        name: group.name,
        diversity: group.diversity_score
      }
      group.users.each do |user|
        students[user.id][ :group_id ] = group.id
      end
    end

    respond_to do |format|
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
    group = Group.find(params[:group_id])
    group&.delete
    redirect_to @project
  end

  def add_group
    @title = t('.title')
    @project = Project.find(params[:project_id])
    group = Group.create(name: params[:group_name], project: @project)

    redirect_to @project, notice: t('projects.group_create_success')
  end

  def rescore_group
    @title = t('.title')
    group = @project.groups.where(id: params[:group_id]).take
    if group.present?
      group.calc_diversity_score
      group.save
      logger.debug group.errors.full_messages unless group.errors.empty?

      respond_to do |format|
        format.json do
          get_groups
        end
        format.html do
          redirect_to @project, notice: t('projects.diversity_calculated')
        end
      end
    else
      redirect_to @project, notice: t('projects.wrong_group')
    end
  end

  def rescore_groups
    @title = t('.title')
    @project.groups.each do |group|
      group.calc_diversity_score
      group.save
      logger.debug group.errors.full_messages unless group.errors.empty?
    end

    respond_to do |format|
      format.json do
        get_groups
      end
      format.html do
        redirect_to @project, notice: t('projects.diversities_calculated')
      end
    end
  end

  def activate
    @title = t('projects.show.title')
    if current_user.is_admin? ||
       @project.course.get_user_role(current_user) == 'instructor'
      @project.active = true
      @project.save
      logger.debug @project.errors.full_messages unless @project.errors.empty?
    end
    render :show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    if params[:id].blank? || params[:id] == 'new'
      course = Course.find(params[:course_id])
      p_test = course.projects.new
      p_test.start_date = course.start_date
      p_test.end_date = course.end_date
    else
      p_test = Project.find(params[:id])
    end

    if current_user.is_admin?
      @project = p_test
    elsif p_test.course.rosters.instructor.where(user: current_user).nil?
      @course = @project.course
      redirect_to @course if @project.nil?
    else
      @project = p_test
    end
  end

  def project_params
    params.require(:project).permit(:course_id, :name, :description, :start_date,
                                    :end_date, :start_dow, :end_dow, :active, :factor_pack_id,
                                    :style_id, groups: [:name])
  end
end
