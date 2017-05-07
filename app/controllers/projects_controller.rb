# frozen_string_literal: true
class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :check_admin, except: [:next, :diagnose, :react]

  def show
    @title = "Project Details"
  end

  def edit
    @title = "Edit Project"
  end

  # GET /admin/coures
  def index
    @title = "List of Projects"
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
    @title = "New Project"
    @project = Project.new
    @project.course = Course.find params[:course_id]
    @project.start_date = @project.course.start_date
    @project.end_date = @project.course.end_date
  end

  def create
    @title = "New Project"
    @project = Project.new(project_params)
    @project.course = Course.find(@project.course_id)
    if @project.save
      notice = 'Project was successfully created.'
      notice += "Don't forget to activate it!" unless @project.active
      redirect_to @project, notice: notice
    else
      render :new
    end
  end

  def update
    @title = "Edit Project"
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
        logger.debug group.errors.full_messages unless group.errors.nil?
      end
      notice = 'Project was successfully updated.'
      notice += "Don't forget to activate it when you're done editing it." unless @project.active
      redirect_to @project, notice: notice
    else
      render :edit
    end
  end

  def destroy
    @course = @project.course
    @project.destroy
    redirect_to @course, notice: 'Project was successfully destroyed.'
  end

  def remove_group
    group = Group.find(params[:group_id])
    group&.delete
    redirect_to show
  end

  def add_group
    @title = "Project Details"
    @project = Project.find(params[:project_id])
    group = Group.create(name: params[:group_name], project: @project)

    flash.now[:notice] = 'Group successfully created'
    render :show
  end

  def activate
    @title = "Project Details"
    project = Project.find(params[:project_id])
    if @current_user.is_admin? ||
       project.course.get_roster_for_user(@current_user).role.name == 'Instructor'
      project.active = true
      project.save
    end
    @project = project
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

  def check_admin
    redirect_to root_path unless @current_user.is_admin? || @current_user.is_instructor?
  end

  def project_params
    params.require(:project).permit(:course_id, :name, :description, :start_date,
                                    :end_date, :start_dow, :end_dow, :active, :factor_pack_id,
                                    :style_id, groups: [:name])
  end
end
