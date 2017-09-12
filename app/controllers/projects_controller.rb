# frozen_string_literal: true
class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :activate,
                                     :rescore_group, :rescore_groups]
  before_action :check_editor, except: [:next, :diagnose, :react,
                                        :rescore_group, :rescore_groups,
                                        :show, :index]
  before_action :check_viewer, only: [:show, :index]

  def show
    @title = t('.title')
  end

  def edit
    @title = t('.title')
  end

  def index
    @title = t('.title')
    @projects = []
    if @current_user.is_admin?
      @projects = Project.all
    else
      rosters = @current_user.rosters.instructorships
      rosters.each do |roster|
        @projects.concat roster.course.projects.to_a
      end
    end
  end

  def new
    @title = t('.title')
    @project = Project.new
    @project.course = Course.find params[:course_id]
    @project.start_date = @project.course.start_date
    @project.end_date = @project.course.end_date
  end

  def create
    @title = t('.title')
    @project = Project.new(project_params)
    @project.course = Course.find(@project.course_id)
    if @project.save
      notice = @project.active ?
            t('projects.create_success') :
            t('projects.create_success_inactive')
      redirect_to @project, notice: notice
    else
      render :new
    end
  end

  def update
    @title = t('projects.edit.title')
    if @project.update(project_params)
      groups_users = {}
      @project.groups.each do |group|
        groups_users[group] = []
        new_name = params['group_' + group.id.to_s]
        group.name = new_name unless new_name.blank?
      end

      @project.course.enrolled_students.each do |user|
        gid = params['user_group_' + user.id.to_s]
        unless gid.blank? || gid.to_i == -1
          group = Group.find(gid)
          groups_users[group] << user
        end
      end
      groups_users.each do |group, users_array|
        group.users = users_array
        group.save
        logger.debug group.errors.full_messages unless group.errors.empty?
      end
      notice = @project.active ?
            t('projects.update_success') :
            t('projects.update_success_inactive')
      redirect_to @project, notice: notice
    else
      render :edit
    end
  end

  def destroy
    @course = @project.course
    @project.destroy
    redirect_to @course, notice: t('projects.destroy_success')
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

      redirect_to @project, notice: t('projects.diversity_calculated')
    else
      redirect_to @project, notice: t('projects.wrong_group')
    end
  end

  def rescore_groups
    @title = t('.title')
    @project.groups.each do |group|
      group.calc_diversity_score
      group.save
    end

    redirect_to @project, notice: t('projects.diversities_calculated')
  end

  def activate
    @title = t('.title')
    if @current_user.is_admin? ||
       @project.course.get_roster_for_user(@current_user).role.code == 'inst'
      @project.active = true
      @project.save
    end
    render :show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    p_test = Project.find(params[:id])
    if @current_user.is_admin?
      @project = p_test
    else
      if p_test.course.rosters.instructorships.where(user: @current_user).nil?
        @course = @project.course
        redirect_to @course if @project.nil?
      else
        @project = p_test
      end
    end
  end

  def check_viewer
    redirect_to root_path unless @current_user.is_admin? ||
                                 @current_user.is_instructor? ||
                                 @current_user.is_researcher?
  end

  def check_editor
    redirect_to root_path unless @current_user.is_admin? || @current_user.is_instructor?
  end

  def project_params
    params.require(:project).permit(:course_id, :name, :description, :start_date,
                                    :end_date, :start_dow, :end_dow, :active, :factor_pack_id,
                                    :style_id, groups: [:name])
  end
end
