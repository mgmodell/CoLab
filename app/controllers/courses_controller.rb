# frozen_string_literal: true
class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy, :add_students, :add_instructors]
  before_action :check_admin, except: [:next, :diagnose, :react, :accept_roster, :decline_roster]

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
    @course.school = @current_user.school unless @current_user.school.nil?
    @course.start_date = Date.yesterday
    @course.end_date = Date.tomorrow.end_of_day
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
        @course.school = School.find(@course.school_id)
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
    @course.add_instructors_by_email params[:addresses]
    respond_to do |format|
      format.html { redirect_to @course, notice: 'Instructor(s) have been invited.' }
      format.json { render :show, status: :ok, location: @course }
    end
  end

  def accept_roster
    r = Roster.student.where(id: params[:roster_id], user: @current_user).take
    if r.nil?
      flash[:notice] = 'You can only accept your own enrollments'
    else
      r.role = Role.enrolled.take
      r.save
    end
    flash.keep
    redirect_to :root
  end

  def decline_roster
    r = Roster.student.where(id: params[:roster_id], user: @current_user).take
    if r.nil?
      flash[:notice] = 'You can only decline your own enrollments'
    else
      r.role = Role.declined.take
      r.save
    end
    flash.keep
    redirect_to :root
  end

  def remove_instructor
    r = Roster.find(params[:roster_id])
    if !@current_user.is_instructor? && !current_user.is_admin?
      flash[:notice] = "You are not permitted to make that sort of change."
      flash.keep
      redirect_to :root
    elsif r.course.roster.instructorships < 2
      flash[:notice] = "Courses must always have at least one instructor."
      flash.keep
      redirect_to :root
    elsif r.nil? 
      flash[:notice] = 'This is not an instructor in this course'
      flash.keep
      redirect_to :root
    else
      r.destroy
      redirect_to course_path(r.course)
    end
  end

  def drop_student
    r = Roster.find(params[:roster_id])
    if r.nil?
      flash[:notice] = 'That is not a valid user-course relationship'
      flash.keep
      redirect_to :root
    else
      instructor_action = r.user != @current_user
      if !instructor_action && r.user != @current_user
        flash[:notice] = "You are not permitted to make that sort of change."
        flash.keep
        redirect_to :root
      else
        r.role = Role.dropped.take
        r.save
        if instructor_action
          redirect_to course_path(r.course)
        else
          redirect_to :root
        end
      end
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

  def check_admin
    redirect_to root_path unless @current_user.is_admin? || @current_user.is_instructor?
  end

  def course_params
    params.require(:course).permit(:name, :number, :school_id, :start_date, :end_date,
                                   :description, :timezone, rosters: [:role_id])
  end
end
