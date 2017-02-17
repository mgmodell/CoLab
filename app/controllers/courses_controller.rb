class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy, :add_students]

  def show; end

  def edit; end

  # GET /admin/coures
  def index
    @courses = []
    if @current_user.admin?
      @courses = Course.all
    else
      rosters = @current_user.rosters.instructorships
      rosters.each do |roster|
        @courses << roster.course
      end
    end
  end

  def new
    @course = Course.new
    @course.timezone = @current_user.timezone
    role = Role.instructor.take
    @course.rosters << Roster.new(role: role, user: @current_user)
  end

  def create
    @course = Course.new(course_params)
    role = Role.instructor.take
    @course.rosters << Roster.new(role: role, user: @current_user)

    respond_to do |format|
      if @course.save
        format.html { redirect_to url: course_url(@course), notice: 'Course was successfully created.' }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to course_path(@course), notice: 'Course was successfully updated.' }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url, notice: 'Course was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_students
    @course.add_students_by_email params[:addresses]
    respond_to do |format|
      format.html { redirect_to @course, notice: 'Students have been invited.' }
      format.json { render :show, status: :ok, location: @course }
    end
  end

  def add_instructors
    @course.add_students_by_email params[:addresses]
    respond_to do |format|
      format.html { redirect_to @course, notice: 'Students have been invited.' }
      format.json { render :show, status: :ok, location: @course }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    if @current_user.is_admin?
      @course = Course.find(params[:id])
    else
      @course = @current_user.rosters.instructorships.where(course_id: params[:id]).take.course
      redirect_to :show if @course.nil?
    end
  end

  def course_params
    params.require( :course ).permit(:name, :number, :school_id, :start_date, :end_date, 
                                      :description, :timezone, rosters: [:role_id])
  end
end
