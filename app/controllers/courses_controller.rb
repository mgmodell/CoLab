# frozen_string_literal: true

class CoursesController < ApplicationController
  layout 'admin', except: %i[self_reg self_reg_confirm]
  before_action :set_course, only: %i[show edit update destroy
                                      add_students add_instructors calendar
                                      new_from_template ]
  before_action :set_reg_course, only: %i[self_reg self_reg_confirm]
  before_action :check_admin, only: %i[new create]
  before_action :check_editor, except: %i[next diagnose react accept_roster
                                          decline_roster show index
                                          self_reg_confirm self_reg]
  before_action :check_viewer, except: %i[next diagnose react accept_roster
                                          decline_roster
                                          self_reg_confirm self_reg]
  skip_before_action :authenticate_user!, only: %i[qr get_quote]

  def show
    @title = t('.title')
  end

  def edit
    @title = t('.title')
  end

  def qr
    require 'rqrcode'
    qrcode = RQRCode::QRCode.new(self_reg_url)
    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 120
    )
    send_data png.to_s,
              type: 'image/png',
              disposition: 'inline'
  end

  def self_reg; end

  def self_reg_confirm
    roster = Roster.where(user: current_user, course: @course).take
    if roster.nil?
      roster = @course.rosters.create(role: Roster.roles[:requesting_student], user: current_user)
    else
      if !((roster.enrolled_student? || roster.invited_student? ||
              roster.instructor? || roster.assistant?))
        roster.requesting_student!
      elsif roster.invited_student?
        roster.enrolled_student!
      end
    end
    roster.save
    logger.debug roster.errors.full_messages unless roster.errors.empty?

    redirect_to controller: 'home', action: 'index'
  end

  def score_sheet
    require 'csv'
    course = Course
             .includes(rosters: :user, bingo_games:
        %i[candidate_lists bingo_boards])
             .joins(rosters: :user)
             .left_outer_joins(bingo_games: %i[bingo_boards candidate_lists])
             .find_by(id: params[:id])

    headers = ['First Name', 'Last Name', 'Email',
               'Assessment', 'Experience', 'Bingo Performance']

    bingo_games = course.bingo_games.sort_by(&:end_date)
    headers << 'Terms Lists'
    bingo_games.each do |bingo_game|
      headers << bingo_game.end_date
    end
    headers << 'Worksheets'
    bingo_games.each do |bingo_game|
      headers << bingo_game.end_date
    end
    csv = CSV.generate do |doc|
      doc << headers

      course.rosters.enrolled.each do |roster|
        user = roster.user
        user_row = [
          user.first_name,
          user.last_name,
          user.email,
          user.get_assessment_performance(course_id: course.id),
          user.get_experience_performance(course_id: course.id),
          user.get_bingo_performance(course_id: course.id)
        ]
        terms_lists = []
        worksheets = []
        bingo_games.each do |bingo_game|
          list = bingo_game.candidate_lists.find_by user_id: user.id
          terms_lists << if list.nil?
                           0
                         else
                           list.cached_performance
                         end

          worksheet = bingo_game.bingo_boards.worksheet.find_by user_id: user.id
          worksheets << if worksheet.nil? || worksheet.performance.blank?
                          0
                        else
                          worksheet.performance
                        end
        end
        # Add a spacer
        user_row << nil
        user_row.concat(terms_lists)
        user_row << nil
        user_row.concat(worksheets)
        doc << user_row
      end
    end

    respond_to do |format|
      format.csv do
        send_data(csv,
                  filename: "#{course.name}-#{course.number}.csv")
      end
    end
  end

  def reg_requests
    # Pull any requesting students for review
    courses = current_user.rosters.faculty.collect(&:course)
    waiting_student_requests = Roster.requesting_student
                                     .where(course: courses)
    respond_to do |format|
      format.json do
        resp = waiting_student_requests.collect do |r|
          { id: r.id, first_name: r.user.first_name,
            last_name: r.user.last_name,
            course_name: r.course.name,
            course_number: r.course.number }
        end
        render json: resp
      end
    end
  end

  def proc_reg_requests
    roster = Roster.find params[:roster_id]
    if roster.requesting_student?
      if params[:decision]
        roster.enrolled_student!
      else
        roster.rejected_student!
      end
    end
    roster.save
    logger.debug roster.errors.full_messages unless roster.errors.empty?
    reg_requests
  end

  def calendar
    events = @course.get_activities
                    .reduce([]) { |acc, add| acc.concat add.get_events user: current_user }

    respond_to do |format|
      format.json do
        render json: events.as_json
      end
    end
  end

  # GET /admin/coures
  def index
    @title = t('.title')
    @courses = []
    if current_user.admin?
      @courses = Course.includes(:school).all
    else
      rosters = current_user.rosters.instructor.includes(course: :school)
      rosters.each do |roster|
        @courses << roster.course
      end
    end

    respond_to do |format|
      format.html do
      end
      format.json do
        resp = @courses.collect do |r|
          { id: r.id,
            name: r.name,
            number: r.number,
            school_name: r.school.name,
            start_date: r.start_date,
            end_date: r.end_date,
            faculty_count: r.rosters.faculty.size,
            student_count: r.rosters.students.size,
            project_count: r.projects.size,
            experience_count: r.experiences.size,
            bingo_game_count: r.bingo_games.size
          }
        end
        render json: resp
      end
    end
  end

  def new
    @title = t('.title')
    @course = nil
    @course = if current_user.school.nil?
                Course.new
              else
                current_user.school.courses.new
              end
    @course.timezone = current_user.timezone
    @course.start_date = Date.tomorrow.beginning_of_day
    @course.end_date = 1.month.from_now.end_of_day
    @course.rosters.new(role: Roster.roles[:instructor], user: current_user)
  end

  def new_from_template
    new_start = Chronic.parse(params[:start_date])

    copied_course = @course.copy_from_template new_start: new_start
    if copied_course.errors.empty?
      redirect_to courses_url, notice: t('courses.copy_success')
    else
      redirect_to courses_url, notice: t('courses.copy_fail')
    end
  end

  def create
    @title = t('courses.new.title')
    @course = Course.new(course_params)
    @course.rosters << Roster.new(role: Roster.roles[:instructor], user: current_user)

    if @course.save
      redirect_to courses_url, notice: t('courses.create_success')
    else
      logger.debug @course.errors.full_messages unless @course.errors.empty?
      render :new
    end
  end

  def update
    @title = t('courses.edit.title')
    if @course.update(course_params)
      @course.school = School.find(@course.school_id)
      redirect_to course_path(@course), notice: t('courses.update_success')
    else
      logger.debug @course.errors.full_messages unless @course.errors.empty?
      render :edit
    end
  end

  def destroy
    @course.destroy
    redirect_to courses_url, notice: t('courses.destroy_success')
  end

  def add_students
    count = @course.add_students_by_email params[:addresses]
    redirect_to @course, notice: t('courses.students_invited', count: count)
  end

  def add_instructors
    count = @course.add_instructors_by_email params[:addresses]
    redirect_to @course, notice: t('courses.instructor_invited', count: count)
  end

  def accept_roster
    r = Roster.students.where(id: params[:roster_id], user: current_user).take
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
    r = Roster.students.where(id: params[:roster_id], user: current_user).take
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
    if !current_user.is_instructor? && !current_user.is_admin?
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
      instructor_action = r.user != current_user
      if !instructor_action && r.user != current_user
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
    if current_user.is_admin?
      @course = Course.includes(:users).find(params[:id])
    else
      @course = current_user
                .rosters.instructor
                .where(course_id: params[:id]).take.course
      redirect_to :show if @course.nil?
    end
  end

  def set_reg_course
    @course = Course.find(params[:id])
  end

  def check_viewer
    redirect_to root_path unless current_user.is_admin? ||
                                 current_user.is_instructor? ||
                                 current_user.is_researcher?
  end

  def check_admin
    redirect_to root_path unless current_user.is_admin?
  end

  def check_editor
    unless current_user.is_admin? || current_user.is_instructor?
      redirect_to root_path
    end
  end

  def course_params
    params.require(:course).permit(:name, :number, :school_id, :start_date, :end_date,
                                   :description, :timezone, rosters: [:role])
  end
end
