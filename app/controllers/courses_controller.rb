# frozen_string_literal: true
class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy, :add_students, :add_instructors]
  before_action :check_admin, except: [:next, :diagnose, :react, :accept_roster, :decline_roster]

  def show
    @title = t( '.title' )
  end

  def edit
    @title = t( '.title' )
  end

  # GET /admin/coures
  def index
    @title = t( '.title' )
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
    @title = t( '.title' )
    @course = Course.new
    @course.timezone = @current_user.timezone
    @course.school = @current_user.school unless @current_user.school.nil?
    @course.start_date = Date.tomorrow.beginning_of_day
    @course.end_date = 1.month.from_now.end_of_day
    role = Role.instructor.take
    @course.rosters << Roster.new(role: role, user: @current_user)
  end

  def create
    @title = t( 'courses.new.title' )
    @course = Course.new(course_params)
    role = Role.instructor.take
    @course.rosters << Roster.new(role: role, user: @current_user)

    if @course.save
      redirect_to url: course_url(@course), notice: t( 'courses.create_success' )
    else
      render :new
    end
  end

  def update
    @title = t( '.title' ) 
    if @course.update(course_params)
      @course.school = School.find(@course.school_id)
      redirect_to course_path(@course), notice: t( 'courses.update_success' )
    else
      render :edit
    end
  end

  def destroy
    @course.destroy
    redirect_to courses_url, notice: t( 'courses.destroy_success' )
  end

  def add_students
    @course.add_students_by_email params[:addresses]
    redirect_to @course, notice: t( 'courses.students_invited' )
  end

  def add_instructors
    @course.add_instructors_by_email params[:addresses]
    redirect_to @course, notice: t( 'courses.instructor_invited' )
  end

  def accept_roster
    r = Roster.student.where(id: params[:roster_id], user: @current_user).take
    if r.nil?
      flash[:notice] = t( 'courses.accept_fail' )
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
      flash[:notice] = t( 'courses.decline_fail' )
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
      flash[:notice] = t( 'courses.permission_fail' )
      flash.keep
      redirect_to :root
    elsif r.course.rosters.instructorships.count < 2
      flash[:notice] = t( 'courses.last_instructor' )
      flash.keep
      redirect_to :root
    elsif r.nil?
      flash[:notice] = t( 'courses.not_instructor' )
      flash.keep
      redirect_to :root
    else
      r.destroy
      redirect_to course_path(r.course)
    end
  end

  def re_invite_student
    user = User.find(params[:user_id])
    AdministrativeMailer.re_invite(user).deliver_later
    redirect_to :admin
  end

  def drop_student
    r = Roster.find(params[:roster_id])
    if r.nil?
      flash[:notice] = t( 'courses.no_roster' )
      flash.keep
      redirect_to :root
    else
      instructor_action = r.user != @current_user
      if !instructor_action && r.user != @current_user
        flash[:notice] = t( 'courses.permission_fail' )
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
