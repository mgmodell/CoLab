# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :set_course, only: %i[show edit update destroy add_students add_instructors, new_from_template]
  before_action :check_admin, only: %i[new create]
  before_action :check_editor, except: %i[next diagnose react accept_roster decline_roster show index]
  before_action :check_viewer, except: %i[next diagnose react accept_roster decline_roster]

  def show
    @title = t('.title')
  end

  def edit
    @title = t('.title')
  end

  # GET /admin/coures
  def index
    @title = t('.title')
    @courses = []
    if @current_user.admin?
      @courses = Course.includes(:school).all
    else
      rosters = @current_user.rosters.instructor.includes(course: :school)
      rosters.each do |roster|
        @courses << roster.course
      end
    end
  end

  def new
    @title = t('.title')
    @course = Course.new
    @course.timezone = @current_user.timezone
    @course.school = @current_user.school unless @current_user.school.nil?
    @course.start_date = Date.tomorrow.beginning_of_day
    @course.end_date = 1.month.from_now.end_of_day
    @course.rosters << Roster.new(role: Roster.roles[:instructor], user: @current_user)
  end

  def new_from_template
    puts "\t\t****W00T!"
    start_date = params[:start_date]
    #Timezone checking here
    course_tz = ActiveSupport::TimeZone.new( @course.timezone )
    date_difference = Chronic.parse( start_date ) - @course.start_date + course_tz.utc_offset
    
    #create the course
    new_course = Course.new
    new_course.name = "Copy of #{@course.name}"
    new_course.number = "Copy of #{@course.number}"
    new_course.description = @course.description
    new_course.timezone = @course.timezone
    new_course.start_date = @course.start_date + date_difference
    new_course.end_date = @course.end_date + date_difference

    #copy the rosters
    @course.rosters.faculty.each do |roster|
      new_obj = Roster.new
      new_obj.role = roster.role
      new_obj.user = roster.user
      new_course.rosters << new_obj
    end

    #copy the projects
    proj_hash = {}
    @course.projects.each do |project|
      new_obj = Project.new
      new_obj.name = project.name
      new_obj.style = project.style
      new_obj.factor_pack = project.factor_pack
      new_obj.start_date = project.start_date + date_difference
      new_obj.end_date = project.end_date + date_difference
      new_course.projects << new_obj
      proj_hash[ project ] = new_obj
    end

    #copy the experiences
    @course.experiences.each do |experience|
      new_obj = Experience.new
      new_obj.name = experience.name
      new_obj.start_date = experience.start_date + date_difference
      new_obj.end_date = experience.end_date + date_difference
      new_course.experiences << new_obj
    end

    #copy the bingo! games
    @course.bingo_games.each do |bingo_game|
      new_obj = BingoGame.new
      new_obj.topic = bingo_game.topic
      new_obj.description = bingo_game.description
      new_obj.link = bingo_game.link
      new_obj.source = bingo_game.source
      new_obj.group_option = bingo_game.group_option
      new_obj.individual_count = bingo_game.individual_count
      new_obj.lead_time = bingo_game.lead_time
      new_obj.group_discount = bingo_game.group_discount
      new_obj.project = bingo_game.project.nil? ?
        nil : proj_hash[ bingo_game.project ]
      new_obj.start_date = bingo_game.start_date + date_difference
      new_obj.end_date = bingo_game.end_date + date_difference
      new_course.bingo_games << new_obj
    end

    if new_course.save
      redirect_to courses_url, notice: t('courses.copy_success')
    else
      redirect_to courses_url, notice: t('courses.copy_fail')
    end
      
  end

  def create
    @title = t('courses.new.title')
    @course = Course.new(course_params)
    @course.rosters << Roster.new(role: Roster.roles[:instructor], user: @current_user)

    if @course.save
      redirect_to courses_url, notice: t('courses.create_success')
    else
      render :new
    end
  end

  def update
    @title = t('courses.edit.title')
    if @course.update(course_params)
      @course.school = School.find(@course.school_id)
      redirect_to course_path(@course), notice: t('courses.update_success')
    else
      render :edit
    end
  end

  def destroy
    @course.destroy
    redirect_to courses_url, notice: t('courses.destroy_success')
  end

  def add_students
    @course.add_students_by_email params[:addresses]
    redirect_to @course, notice: t('courses.students_invited')
  end

  def add_instructors
    @course.add_instructors_by_email params[:addresses]
    redirect_to @course, notice: t('courses.instructor_invited')
  end

  def accept_roster
    r = Roster.students.where(id: params[:roster_id], user: @current_user).take
    if r.nil?
      flash[:notice] = t('courses.accept_fail')
    else
      r.role = Roster.roles[:enrolled_student]
      r.save
    end
    flash.keep
    redirect_to :root
  end

  def decline_roster
    r = Roster.students.where(id: params[:roster_id], user: @current_user).take
    if r.nil?
      flash[:notice] = t('courses.decline_fail')
    else
      r.role = Roster.roles[:declined_student]
      r.save
    end
    flash.keep
    redirect_to :root
  end

  def remove_instructor
    r = Roster.find(params[:roster_id])
    if !@current_user.is_instructor? && !current_user.is_admin?
      flash[:notice] = t('courses.permission_fail')
      flash.keep
      redirect_to :root
    elsif r.course.rosters.instructor.count < 2
      flash[:notice] = t('courses.last_instructor')
      flash.keep
      redirect_to :root
    elsif r.nil?
      flash[:notice] = t('courses.not_instructor')
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
      flash[:notice] = t('courses.no_roster')
      flash.keep
      redirect_to :root
    else
      instructor_action = r.user != @current_user
      if !instructor_action && r.user != @current_user
        flash[:notice] = t('courses.permission_fail')
        flash.keep
        redirect_to :root
      else
        r.role = Roster.roles[:dropped_student]
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
      @course = Course.includes( :users ).find(params[:id])
    else
      @course = @current_user
        .rosters.instructor
        .where(course_id: params[:id]).take.course
      redirect_to :show if @course.nil?
    end
  end

  def check_viewer
    redirect_to root_path unless @current_user.is_admin? ||
                                 @current_user.is_instructor? ||
                                 @current_user.is_researcher?
  end

  def check_admin
    redirect_to root_path unless @current_user.is_admin?
  end

  def check_editor
    redirect_to root_path unless @current_user.is_admin? || @current_user.is_instructor?
  end

  def course_params
    params.require(:course).permit(:name, :number, :school_id, :start_date, :end_date,
                                   :description, :timezone, rosters: [:role])
  end
end
