# frozen_string_literal: true

class CoursesController < ApplicationController
  include PermissionsCheck

  before_action :set_course, only: %i[show update destroy
                                      add_students add_instructors calendar
                                      new_from_template get_users ]
  before_action :set_reg_course, only: %i[self_reg_init self_reg_confirm self_reg_init]
  before_action :check_admin, only: %i[new create]
  before_action :check_editor, except: %i[accept_roster
                                          decline_roster show index
                                          self_reg_confirm qr reg_requests
                                          self_reg_init ]
  before_action :check_viewer, except: %i[accept_roster
                                          decline_roster
                                          self_reg_confirm qr reg_requests
                                          self_reg_init ]
  skip_before_action :authenticate_user!, only: %i[qr]

  def show
    respond_to do | format |
      format.json do
        response = {
          course: @course.as_json(
            only: %i[ id name number description timezone
                      school_id start_date end_date
                      consent_form_id ]
          ),
          consent_forms: ConsentForm.where( active: true ).as_json(
            only: %i[id name]
          )
        }
        if current_user.is_instructor? || current_user.is_admin?
          anon = current_user.anonymize?
          if @course.id&.positive?
            response[:new_activity_links] = [
              { name: 'Group Experience', link: 'experience' },
              { name: 'Project', link: 'project' },
              { name: 'Terms List', link: 'bingo_game' },
              { name: 'Assignment', link: 'assignment' }
            ]
            activities = @course.get_activities.collect do | activity |
              {
                id: activity.id,
                name: activity.get_name( anon ),
                active: activity.active,
                type: activity.type,
                start_date: anon ? activity.start_date + @course.anon_offset : activity.start_date,
                end_date: anon ? activity.end_date + @course.anon_offset : activity.end_date,
                link: activity.get_link
              }
            end
            response[:course][:activities] = activities
            response[:course][:reg_link] = course_reg_qr_path( id: @course.id )
          else
            response[:new_activity_links] = []
            response[:course][:activities] = []

          end
        end
        response[:messages] = {}
        render json: response
      end
    end
  end

  def get_users
    @course.rosters
    users = []
    @course.rosters.each do | roster |
      users << {
        id: roster.id
      }
    end

    anon = current_user.anonymize?
    users = @course.rosters.collect do | roster |
      user = roster.user
      {
        id: roster.id,
        first_name: anon ? user.anon_first_name : user.first_name,
        last_name: anon ? user.anon_last_name : user.last_name,
        email: anon ? "#{user.last_name_anon}@mailinator.com" : user.email,
        bingo_data: user.get_bingo_data( course_id: @course.id ),
        bingo_performance: user.get_bingo_performance( course_id: @course.id ),
        assessment_performance: user.get_assessment_performance( course_id: @course.id ),
        experience_performance: user.get_experience_performance( course_id: @course.id ),
        status: roster.role,
        drop_link: drop_student_path( roster_id: roster.id ),
        reinvite_link: re_invite_student_path( user_id: roster.user.id )
      }
    end
    response = {
      users:,
      add_function: {
        proc_self_reg: proc_course_reg_requests_path,
        instructor: add_instructors_path,
        students: add_students_path
      }
    }
    respond_to do | format |
      format.json do
        render json: response
      end
    end
  end

  def qr
    require 'rqrcode'
    qrcode = RQRCode::QRCode.new( "#{root_url}home/course/#{params[:id]}/enroll" )
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

  def self_reg_confirm
    roster = Roster.find_by( user: current_user, course: @course )
    if roster.nil?
      roster = @course.rosters.create( role: Roster.roles[:requesting_student], user: current_user )
    elsif !(  roster.enrolled_student? || roster.invited_student? ||
              roster.instructor? || roster.assistant? )
      roster.requesting_student!
    elsif roster.invited_student?
      roster.enrolled_student!
    end
    roster.save
    logger.debug roster.errors.full_messages unless roster.errors.empty?

    redirect_to controller: 'home', action: 'index'
  end

  def self_reg_init
    response = {
      course: @course.as_json(
        only: %i[id name number description]
      ),
      enrollable: false
    }

    if @course.end_date < Time.zone.now
      response[:message_header] = 'enroll_failed_title'
      response[:message] = 'self_enroll_course_closed_body'

    else
      roster = Roster.includes( :course ).find_by( user: current_user, course: @course )

      if roster.nil? || roster.dropped_student? ||
         roster.invited_student? || roster.declined_student?

        response[:enrollable] = true
        response[:message_header] = 'enroll_title'
        response[:message] = 'self_enroll_body'

      elsif roster.instructor? || roster.assistant?
        response[:message_header] = 'enroll_failed_title'
        response[:message] = 'self_enroll_instructor_body'

      elsif roster.requesting_student?
        response[:message_header] = 'enroll_title'
        response[:message] = 'self_enroll_already_requested_body'

      elsif roster.enrolled_student?
        response[:message_header] = 'enroll_title'
        response[:message] = 'self_enroll_already_enrolled_body'

      elsif roster.rejected_student?
        response[:message_header] = 'enroll_failed_title'
        response[:message] = 'self_enroll_already_rejected_body'

      end
    end
    respond_to do | format |
      format.json do
        render json: response
      end
    end
  end

  def score_sheet
    require 'csv'
    course = Course
             .includes( rosters: :user, bingo_games:
        %i[candidate_lists bingo_boards] )
             .joins( rosters: :user )
             .left_outer_joins( bingo_games: %i[bingo_boards candidate_lists] )
             .find_by( id: params[:id] )

    headers = ['First Name', 'Last Name', 'Email',
               'Assessment', 'Experience', 'Bingo Performance']

    bingo_games = course.bingo_games.sort_by( &:end_date )
    headers << 'Terms Lists'
    bingo_games.each do | bingo_game |
      headers << bingo_game.end_date
    end
    headers << 'Worksheets'
    bingo_games.each do | bingo_game |
      headers << bingo_game.end_date
    end
    csv = CSV.generate do | doc |
      doc << headers

      course.rosters.enrolled.each do | roster |
        user = roster.user
        user_row = [
          user.first_name,
          user.last_name,
          user.email,
          user.get_assessment_performance( course_id: course.id ),
          user.get_experience_performance( course_id: course.id ),
          user.get_bingo_performance( course_id: course.id )
        ]
        terms_lists = []
        worksheets = []
        bingo_games.each do | bingo_game |
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
        user_row.concat( terms_lists )
        user_row << nil
        user_row.concat( worksheets )
        doc << user_row
      end
    end

    respond_to do | format |
      format.csv do
        send_data( csv,
                   filename: "#{course.name}-#{course.number}.csv" )
      end
    end
  end

  def reg_requests
    # Pull any requesting students for review
    courses = current_user.rosters.faculty.collect( &:course )
    waiting_student_requests = Roster.requesting_student
                                     .where( course: courses )
    respond_to do | format |
      format.json do
        resp = waiting_student_requests.collect do | r |
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
                    .reduce( [] ) { | acc, add | acc.concat add.get_events user: current_user }

    respond_to do | format |
      format.json do
        render json: events.as_json
      end
    end
  end

  # GET /admin/coures
  def index
    @courses = []
    if current_user.admin?
      @courses = Course.includes( :school ).all
    else
      rosters = current_user.rosters.instructor.includes( course: :school )
      rosters.each do | roster |
        @courses << roster.course
      end
    end

    respond_to do | format |
      format.json do
        resp = @courses.collect do | r |
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
            bingo_game_count: r.bingo_games.size,
            actions: {
              course_scores: course_scores_path( id: r.id ),
              create_copy: copy_course_path( id: r.id )
            } }
        end
        render json: resp
      end
    end
  end

  def new
    @course = nil
    @course = if current_user.school.nil?
                Course.new
              else
                current_user.school.courses.new
              end
    @course.timezone = current_user.timezone
    @course.start_date = Date.tomorrow.beginning_of_day
    @course.end_date = 1.month.from_now.end_of_day
    @course.rosters.new( role: Roster.roles[:instructor], user: current_user )
    #    respond_to do |format|
    #      format.json do
    #        render json: { course: @course.as_json }
    #      end
    #    end
  end

  def new_from_template
    new_start = Chronic.parse( params[:start_date] )

    copied_course = @course.copy_from_template( new_start: )
    respond_to do | format |
      format.json do
        notice = copied_course.errors.empty? ? t( 'courses.copy_success' ) : t( 'courses.copy_fail' )
        render json: { messages: { main: notice } }
      end
    end
  end

  def create
    @course = Course.new( course_params )
    @course.rosters << Roster.new( role: Roster.roles[:instructor], user: current_user )

    if @course.save
      notice = t( 'courses.create_success' )
      respond_to do | format |
        format.json do
          response = {
            course: @course.as_json(
              only: %i[ id name number description timezone
                        school_id start_date end_date
                        consent_form_id ]
            ),
            messages: { main: notice }
          }
          render json: response
        end
      end
    else
      logger.debug @course.errors.full_messages unless @course.errors.empty?
      respond_to do | format |
        format.json do
          messages = @course.errors.as_json
          messages[:main] = 'Please review the problems below'
          render json: {
            messages:
          }
        end
      end
    end
  end

  def update
    if @course.update( course_params )
      notice = t( 'courses.create_success' )
      respond_to do | format |
        format.json do
          response = {
            course: @course.as_json(
              only: %i[ id name number description timezone
                        school_id start_date end_date
                        consent_form_id ]
            ),
            messages: { main: notice }
          }
          render json: response
        end
      end
    else
      logger.debug @course.errors.full_messages unless @course.errors.empty?
      respond_to do | format |
        format.json do
          messages = @course.errors.to_hash.store( :main, 'Please review the problems below' )
          response = {
            messages:
          }
          render json: response
        end
      end
    end
  end

  def destroy
    @course.destroy
    redirect_to courses_url, notice: t( 'courses.destroy_success' )
  end

  def add_students
    count = @course.add_students_by_email params[:addresses]
    msg = t( 'courses.students_invited', count: )
    respond_to do | format |
      format.json do
        render json: { messages: { main: msg } }
      end
    end
  end

  def add_instructors
    count = @course.add_instructors_by_email params[:addresses]
    msg = t( 'courses.instructor_invited', count: )
    respond_to do | format |
      format.json do
        render json: { messages: { main: msg } }
      end
    end
  end

  def accept_roster
    r = Roster.students.find_by( id: params[:roster_id], user: current_user )
    notice = 'Successfully accepted the course'
    if r.nil?
      notice = t( 'courses.accept_fail' )
    else
      r.role = Roster.roles[:enrolled_student]
      r.save
    end
    respond_to do | format |
      format.json do
        render json: {
          messages: { main: notice }
        }
      end
    end
  end

  def decline_roster
    r = Roster.students.find_by( id: params[:roster_id], user: current_user )
    notice = 'Successfully declined the course'
    if r.nil?
      notice = t( 'courses.decline_fail' )
    else
      r.role = Roster.roles[:declined_student]
      r.save
    end
    respond_to do | format |
      format.json do
        render json: {
          messages: { main: notice }
        }
      end
    end
  end

  def remove_instructor
    r = Roster.find( params[:roster_id] )
    if !current_user.is_instructor? && !current_user.is_admin?
      flash[:notice] = t( 'courses.permission_fail' )
      flash.keep
      redirect_to :root
    elsif r.course.rosters.instructor.count < 2
      flash[:notice] = t( 'courses.last_instructor' )
      flash.keep
      redirect_to :root
    elsif r.nil?
      flash[:notice] = t( 'courses.not_instructor' )
      flash.keep
      redirect_to :root
    else
      r.destroy
      redirect_to course_path( r.course )
    end
  end

  def re_invite_student
    user = User.find( params[:user_id] )
    AdministrativeMailer.re_invite( user ).deliver_later
    respond_to do | format |
      format.json do
        render json: {
          messages: {
            main: message || 'Successfully reinvited'
          }
        }
      end
    end
  end

  def drop_student
    r = Roster.find( params[:roster_id] )
    message = nil
    if r.nil?
      message = t( 'courses.no_roster' )
    else
      instructor_action = r.user != current_user
      if !instructor_action
        message = t( 'courses.permission_fail' )
      else
        r.role = Roster.roles[:dropped_student]
        r.save
        course_path( r.course ) if instructor_action
      end
    end
    respond_to do | format |
      format.json do
        render json: {
          messages: {
            main: message || 'Successfully dropped'
          }
        }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    if current_user.is_admin?
      @course = if params[:id].blank? || 'new' == params[:id]
                  Course.new(
                    school_id: current_user.school_id,
                    timezone: current_user.timezone,
                    start_date: Date.tomorrow.beginning_of_day,
                    end_date: 1.month.from_now.end_of_day
                  )
                else
                  Course.includes( :users ).find( params[:id] )
                end
    else
      @course = Course.find_by id: params[:id]
      # TODO: This can't be right and must be fixed for security later
      # This needs to throw a security error
      redirect_to :show if @course.nil?
    end
  end

  def set_reg_course
    @course = Course.find( params[:id] )
  end

  def course_params
    params.require( :course ).permit( :name, :number, :school_id, :start_date, :end_date,
                                      :description, :timezone, rosters: [:role] )
  end
end
