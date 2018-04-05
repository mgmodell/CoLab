# frozen_string_literal: true

class HomeController < ApplicationController
  protect_from_forgery except: [:get_quote]
  skip_before_action :authenticate_user!, only: %i[demo_start get_quote]

  def index
    @current_user = current_user
    # The first thing we want to do is make sure they've had an opportunity to
    # complete any waiting consent forms
    waiting_consent_logs = @current_user.waiting_consent_logs
    if waiting_consent_logs.count > 0
      redirect_to(controller: 'consent_logs',
                  action: 'edit',
                  consent_form_id: waiting_consent_logs[0].consent_form_id)
    elsif @current_user.rosters.invited_student.count > 0
      @waiting_rosters = current_user.rosters.invited_student
      render :rsvp
    elsif !current_user.welcomed?
      redirect_to edit_user_registration_path(@current_user)
    end
    @first_name = current_user.first_name
    @waiting_student_tasks = current_user.waiting_student_tasks
    @waiting_instructor_tasks = current_user.waiting_instructor_tasks
    @current_location = 'home'
  end

  def get_quote
    quote = Quote.get_quote

    respond_to do |format|
      format.json { render json: quote }
    end
  end

  def states_for_country
    country_code = params[:country_code]
    country = HomeCountry.where(code: country_code).take

    @states = country.nil? ? [] : country.home_states

    # Return the retrieved data
    respond_to do |format|
      format.json
    end
  end

  def check_diversity_score
    emails = params[:emails]
    users = User.joins(:emails).where(emails: { email: emails.split(/[\s,]+/) })
                .includes(:gender, :primary_language,
                          :cip_code, home_state: [:home_country],
                                     reactions: [narrative: [:scenario]])
    @diversity_score = Group.calc_diversity_score_for_group users: users
    @found_users = users.collect do |u|
      { email: u.email,
        name: u.informal_name(false),
        family_name: u.last_name,
        given_name: u.first_name }
    end
    # Return the retrieved data
    respond_to do |format|
      format.json
    end
  end

  # Data transport class
  class Event_
    attr_accessor :name, :task_link, :task_name_post, :type, :status, :group_name
    attr_accessor :course_name, :start_time, :close_date
  end

  def demo_start
    @title = t 'titles.demonstration'
    if @current_user.nil?
      @current_user = User.new(first_name: t(:demo_surname_1),
                               last_name: t(:demo_fam_name_1),
                               timezone: t(:demo_user_tz))
    end

    e = Event_.new
    e.name = t(:demo_group)
    e.task_link = assessment_demo_complete_path
    e.task_name_post = '<br>' + "(#{t :project}: #{t(:demo_project)})"
    e.type = t 'home.sapa'
    e.status = t :not_started
    e.group_name = t(:demo_group)
    e.course_name = t(:demo_course_name)
    e.start_time = 1.day.ago
    e.close_date = 1.day.from_now.end_of_day

    @events = [e]
    e = Event_.new
    e.name = t('candidate_lists.demo_topic')
    e.task_link = bingo_demo_complete_path
    e.task_name_post = ''
    e.type = t 'home.terms_list'
    e.status = '50%'
    e.group_name = t(:demo_group)
    e.course_name = t(:demo_course_name)
    e.start_time = 1.week.ago
    e.close_date = 2.day.from_now.end_of_day
    @events << e
  end
end
