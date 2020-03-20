# frozen_string_literal: true

class HomeController < ApplicationController
  protect_from_forgery except: [:get_quote]
  skip_before_action :authenticate_user!, only: %i[demo_start get_quote]

  def index
    # The first thing we want to do is make sure they've had an opportunity to
    # complete any waiting consent forms
    waiting_consent_logs = current_user.waiting_consent_logs

    if !waiting_consent_logs.empty?
      redirect_to(controller: 'consent_logs',
                  action: 'edit',
                  consent_form_id: waiting_consent_logs[0].consent_form_id)
    elsif current_user.rosters.invited_student.count > 0
      @waiting_rosters = current_user.rosters.invited_student
      render :rsvp
    elsif !current_user.welcomed?
      redirect_to edit_user_registration_path(current_user)
    end
    @first_name = current_user.first_name
    @waiting_student_tasks = current_user.waiting_student_tasks
    @waiting_instructor_tasks = current_user.waiting_instructor_tasks

    current_location = 'home'
  end

  def task_list
    waiting_tasks = current_user.waiting_student_tasks
    waiting_tasks.concat current_user.waiting_instructor_tasks

    respond_to do |format|
      format.json do
        render json: waiting_tasks_hash = waiting_tasks.collect{|t|t.task_data( current_user: current_user )}
      end
    end

  end

  def endpoints
    ep_hash = {}
    case params[:unit]
    when 'home'
      ep_hash = {
        supportAddress: 'Support@CoLab.online',
        logoPath: ActionController::Base.helpers.asset_path( 'CoLab_small.png' ),
        quotePath: get_quote_path,
        moreInfoUrl: 'http://PeerAssess.info',
        demoUrl: demo_start_path,
        homeUrl: root_path,
        taskListUrl: task_list_path,
        diversityScoreFor: check_diversity_score_path
      }
      if user_signed_in?
        ep_hash[ :profileUrl] = edit_user_registration_path(current_user)
        ep_hash[ :logoutUrl ] = logout_path
        if current_user.is_admin? || current_user.is_instructor?
          ep_hash[ :adminUrl] = admin_path
          ep_hash[ :coursesPath ] = courses_path
          ep_hash[ :schoolsPath ] = schools_path
          ep_hash[ :conceptsPath ] = concepts_path
          ep_hash[ :projectsPath ] = projects_path
          ep_hash[ :reportingUrl ] = graphing_path
        end
      end
    when 'project'
      ep_hash = {
        baseUrl: projects_path,
        activateProjectUrl: activate_project_path,
        diversityCheckUrl: check_diversity_score_path,
        groupsUrl: groups_path(id: ''),
        diversityRescoreGroup: rescore_group_path(id: '' ),
        diversityRescoreGroups: rescore_groups_path(id: '' )
      }
    when 'course'
      ep_hash = {
        baseUrl: courses_path,
        scoresUrl: course_scores_path( id: '' )
      }
    when 'experience'
      ep_hash = {
        baseUrl: experience_path
      }
    when 'bingo_game'
      ep_hash = {
        baseUrl: bingo_games_path,
        gameResultsUrl: game_results_path( id: '' )
      }
    when 'concept'
      ep_hash = {
        baseUrl: concepts_path
      }
    end
    # Provide the endpoints
    respond_to do |format|
      format.json do
        render json: ep_hash
      end
    end

  end

  def get_quote
    quote = Quote.get_quote

    respond_to do |format|
      format.json { render json: quote }
    end
  end

  def simple_profile
    respond_to do |format|
      format.json do
        tz = ActiveSupport::TimeZone.new( @current_user.timezone ).tzinfo.name
        render json: {
          id: @current_user.id,
          first_name: @current_user.first_name,
          last_name: @current_user.last_name,
          theme: @current_user.theme.code,
          timezone: tz,
          language: @current_user.language.code,
          is_instructor: @current_user.is_instructor?,
          is_admin: @current_user.is_admin?
        }
      end
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
    diversity_score = Group.calc_diversity_score_for_group users: users
    found_users = users.collect do |u|
      { email: u.email,
        name: u.informal_name(false),
        family_name: u.last_name,
        given_name: u.first_name }
    end
    # Return the retrieved data
    respond_to do |format|
      format.json do
        render json: {
          'found_users': found_users,
          'diversity_score': diversity_score
        }
      end
    end
  end

  # Data transport class
  class Event_
    attr_accessor :name, :task_link, :task_name_post, :type, :status, :group_name
    attr_accessor :course_name, :start_time, :close_date
    attr_accessor :instructor_task
  end

  def demo_start
    @title = t 'titles.demonstration'
    if current_user.nil?
      current_user = User.new(first_name: t(:demo_surname_1),
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
    e.close_date = 3.days.from_now.end_of_day
    e.instructor_task = false

    @events = [e]
    e = Event_.new
    e.name = t('candidate_lists.enter', task: t('candidate_lists.demo_topic'))
    e.task_link = terms_demo_entry_path
    e.task_name_post = ''
    e.type = t 'candidate_lists.submission'
    e.status = '50%'
    e.group_name = t(:demo_group)
    e.course_name = t(:demo_course_name)
    e.start_time = 1.week.ago
    e.close_date = 4.days.from_now.end_of_day
    e.instructor_task = false
    @events << e

    e = Event_.new
    e.name = t('candidate_lists.review', task:
      t('candidate_lists.demo_review_topic'))
    e.task_link = bingo_demo_review_path
    e.task_name_post = ''
    e.type = t :terms_list
    e.status = '0'
    e.group_name = t(:demo_group)
    e.course_name = t(:demo_course_name)
    e.start_time = 3.weeks.ago
    e.close_date = Date.today.end_of_day
    e.instructor_task = true
    # TODO: Enable the candidate review demo
    @events << e

    e = Event_.new
    e.name = t('candidate_lists.play', task:
      t('candidate_lists.demo_bingo_topic'))
    e.task_link = bingo_demo_play_path
    e.task_name_post = ''
    e.type = t 'candidate_lists.distilled'
    e.status = '42 concepts'
    e.group_name = t(:demo_group)
    e.course_name = t(:demo_course_name)
    e.start_time = 2.weeks.ago
    e.close_date = 1.day.from_now.end_of_day
    e.instructor_task = false
    @events << e
  end
end
