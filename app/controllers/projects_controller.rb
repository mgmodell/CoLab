class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :add_group]

  def show; end

  def edit; end

  # GET /admin/coures
  def index
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
    @project = Project.new
    @project.course = Course.find params[:course_id]
  end

  def create
    @project = Project.new(project_params)
    @project.course = Course.find(@project.course_id)
    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_group
    group = Group.create(name: params[:group_name], project: @project)
    redirect_to edit
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    p_test = Project.find(params[:id])
    if @current_user.is_admin?
      @project = p_test
    else
      if p_test.course.rosters.instructorships.where(user: @current_user).nil?
        redirect_to :show if @project.nil?
      else
        @project = p_test
      end
    end
  end

  def project_params
    params.require(:project).permit(:course_id, :name, :description, :start_date,
                                    :end_date, :start_dow, :end_dow, :active, :factor_pack_id,
                                    :style_id, groups: [:name])
  end
end
