# frozen_string_literal: true

class HomeController < ApplicationController
  # protect_from_forgery except: [:get_quote]
  skip_before_action :authenticate_user!, only: %i[index lookups endpoints demo_start get_quote]

  def index; end

  def task_list
    waiting_tasks = current_user.waiting_student_tasks
    waiting_tasks.concat current_user.waiting_instructor_tasks

    waiting_consent_logs = current_user.waiting_consent_logs
    waiting_rosters = current_user.rosters.invited_student

    resp_hash = {
      tasks: waiting_tasks.collect { | t | t.task_data( current_user: ) },
      consent_logs: waiting_consent_logs.collect do | cl |
                      {
                        id: cl.id,
                        consent_form_id: cl.consent_form_id
                      }
                    end,
      waiting_rosters: waiting_rosters.collect do | r |
                         {
                           id: r.id,
                           name: r.course.get_name( false ),
                           startDate: r.course.start_date,
                           endDate: r.course.end_date,
                           acceptPath: accept_roster_path( roster_id: r.id ),
                           declinePath: decline_roster_path( roster_id: r.id )
                         }
                       end
    }
    respond_to do | format |
      format.json do
        render json: resp_hash
      end
    end
  end

  def endpoints
    ep_hash = {
      home: {
        supportAddress: 'Support@CoLab.online',
        logoPath: ActionController::Base.helpers.asset_path( 'CoLab_small.png' ),
        quotePath: get_quote_path,
        moreInfoUrl: '/',
        diversityScoreFor: check_diversity_score_path,
        lookupsUrl: lookups_path,
        taskListUrl: task_list_path,
        oauthValidate: validation_path
      }
    }
    ep_hash[:installment] = {
      baseUrl: edit_installment_path( assessment_id: '' ),
      saveInstallmentUrl: installments_path
    }
    ep_hash[:candidate_list] = {
      baseUrl: get_candidate_list_path( bingo_game_id: '' )
    }
    ep_hash[:candidate_review] = {
      baseUrl: review_bingo_candidates_path( id: '' ),
      reviewSaveUrl: update_bingo_candidates_review_path( id: '' ),
      conceptUrl: bingo_concepts_path( 0 )
    }
    ep_hash[:candidate_results] = {
      baseUrl: my_results_path( id: '' ),
      boardUrl: board_for_game_path( bingo_game_id: '' ),
      conceptsUrl: bingo_concepts_path( id: '' ),
      worksheetUrl: worksheet_for_bingo_path( bingo_game_id: '' )
    }
    if user_signed_in?
      ep_hash[:home][ :courseRegRequestsUrl] = course_reg_requests_path
      ep_hash[:home][ :courseRegUpdatesUrl] = proc_course_reg_requests_path
      ep_hash[:home][ :selfRegUrl] = self_reg_init_path( id: '' )

      ep_hash[:profile] = {
        baseUrl: full_profile_path,
        coursePerformanceUrl: user_courses_path,
        activitiesUrl: user_activities_path,
        consentFormsUrl: user_consents_path,

        addEmailUrl: add_registered_email_path,
        removeEmailUrl: remove_registered_email_path( email_id: '' ),
        setPrimaryEmailUrl: set_primary_registered_email_path( email_id: '' ),
        passwordResetUrl: initiate_password_reset_path,
        passwordUpdateUrl: password_change_path,
        # infrastructure
        statesForUrl: states_for_path( country_code: '' )
      }
      ep_hash[:experience] = {
        baseUrl: next_experience_path( experience_id: '' ),
        diagnosisUrl: diagnose_path,
        reactionUrl: react_path
      }
      ep_hash[:consent_log] = {
        baseUrl: edit_consent_log_path( consent_form_id: '' ),
        consentLogSaveUrl: consent_log_path( id: '' )
      }
      ep_hash[:assignment] = {
        statusUrl: assignment_status_path( id: '' ),
        submissionUrl: submission_path( id: '' ),
        submissionWithdrawalUrl: submission_withdraw_path( id: '' )
      }

      if current_user.is_admin? || current_user.is_instructor?
        ep_hash[ :project] = {
          baseUrl: projects_path,
          activateProjectUrl: activate_project_path,
          diversityCheckUrl: check_diversity_score_path,
          groupsUrl: groups_path( id: '' ),
          diversityRescoreGroup: rescore_group_path( id: '' ),
          diversityRescoreGroups: rescore_groups_path( id: '' )
        }
        ep_hash[ :course] = {
          baseUrl: courses_path,
          courseCreateUrl: new_course_path,
          courseUsersUrl: get_users_path( id: '' ),
          scoresUrl: course_scores_path( id: '' ),
          courseCopyUrl: copy_course_path( id: '' )
        }
        ep_hash[ :school ] = {
          baseUrl: schools_path,
          schoolCreateUrl: new_school_path
        }
        ep_hash[:bingo_game] = {
          baseUrl: bingo_games_path,
          gameResultsUrl: game_results_path( id: '' ),
          worksheetResultsUrl: ws_results_path( id: '' ),
          worksheetScoreUrl: ws_score_path( id: '' )
        }
        ep_hash[:assignment][:baseUrl] = assignments_path
        ep_hash[:experience_admin] = {
          baseUrl: experiences_path
        }
        ep_hash[:concept] = {
          baseUrl: concepts_path
        }
        ep_hash[:rubric] = {
          baseUrl: rubrics_path
        }
        ep_hash[:critique] = {
          baseUrl: assignment_critiques_path( id: '' ),
          showUrl: critique_assignment_path( submission_id: '' ),
          updateUrl: critique_update_path( submission_feedback_id: '' )
        }
        ep_hash[:consent_form] = {
          baseUrl: consent_forms_path,
          consentFormCreateUrl: new_consent_form_path
        }
        ep_hash[:graphing] = {
          dataUrl: graphing_data_path,
          subjectsUrl: graphing_subjects_path,
          projectsUrl: graphing_projects_path
        }
      end
    end

    resources = {
      logged_in: user_signed_in?,
      endpoints: ep_hash,
      lookups: get_lookups
    }
    resources[:profile] = get_profile_hash if user_signed_in?

    # Provide the endpoints
    respond_to do | format |
      format.json do
        render json: resources.as_json
      end
    end
  end

  def get_lookups
    {
      behaviors: Behavior.all.collect do | behavior |
        {
          id: behavior.id,
          name: behavior.name,
          description: behavior.description,
          needs_detail: behavior.needs_detail
        }
      end,
      candidate_feedbacks: CandidateFeedback.all.collect do | candidate_feedback |
        {
          id: candidate_feedback.id,
          name: candidate_feedback.name,
          definition: candidate_feedback.definition,
          credit: candidate_feedback.credit,
          critique: candidate_feedback.critique
        }
      end,
      countries: HomeCountry.all.collect do | country |
        {
          id: country.id,
          name: country.name,
          code: country.code
        }
      end,
      languages: Language.all.collect do | language |
        {
          id: language.id,
          name: language.name,
          code: language.code
        }
      end,
      cip_codes: CipCode.all.collect do | cip_code |
        {
          id: cip_code.id,
          code: cip_code.gov_code,
          name: cip_code.name
        }
      end,
      genders: Gender.all.collect do | gender |
        {
          id: gender.id,
          name: gender.name,
          code: gender.code
        }
      end,
      timezones: HomeController::TIMEZONES,
      timezone_lookup: HomeController::TIMEZONE_HASH,
      oauth_ids: {
        google: Rails.application.credentials.google.client_id
      },
      schools: School.all.collect do | school |
        {
          id: school.id,
          name: school.name,
          timezone: school.timezone
        }
      end
    }
  end

  def lookups
    lookups = get_lookups
    respond_to do | format |
      format.json do
        render json: lookups.as_json
      end
    end
  end

  def get_profile_hash
    profile_hash = {
      user: current_user.as_json(
        only: %i[ id first_name last_name gender_id country
                  timezone theme school_id language_id
                  date_of_birth home_state_id cip_code_id
                  primary_language_id started_school researcher
                  impairment_visual impairment_auditory
                  impairment_motor impairment_cognitive
                  impairment_other primary_language_id
                  welcomed ]
      )

    }
    profile_hash[:user][:is_instructor] = current_user.is_instructor?
    profile_hash[:user][:is_admin] = current_user.is_admin?
    profile_hash[:user][:name] = current_user.name( false )

    profile_hash[:user][:emails] = current_user.emails.as_json(
      only: %i[id email primary],
      methods: ['confirmed?']
    )
    profile_hash
  end

  def full_profile
    respond_to do | format |
      format.json do
        render json: get_profile_hash
      end
    end
  end

  def update_full_profile
    submitted_params = profile_params.to_h

    submitted_params[:welcomed] = true
    if current_user.update( submitted_params )
      notice = 'Profile successfully updated'
      respond_to do | format |
        response = get_profile_hash
        response [:messages] = { main: notice }
        format.json do
          render json: response
        end
      end
    else
      logger.debug current_user.errors.full_messages
      respond_to do | format |
        format.json do
          messages = current_user.errors.to_hash.store( :main, 'Please review the errors below' )
          response = {
            messages:
          }
          render json: response
        end
      end
    end
  end

  # TimeZones constant
  TIMEZONES ||= ActiveSupport::TimeZone.all.collect do | tz |
    {
      name: tz.name,
      stdName: tz.tzinfo.name

    }
  end
  TIMEZONE_HASH = TIMEZONES.each_with_object( {} ) do | next_tz, tz_hash |
    tz_hash[next_tz[:name]] = next_tz[:stdName]
  end

  def get_quote
    quote = Quote.get_quote

    respond_to do | format |
      format.json { render json: quote }
    end
  end

  def simple_profile
    respond_to do | format |
      format.json do
        tz = ActiveSupport::TimeZone.new( @current_user.timezone ).tzinfo.name
        render json: {
          id: @current_user.id,
          name: @current_user.name( false ),
          first_name: @current_user.first_name,
          last_name: @current_user.last_name,
          theme: @current_user.theme,
          welcomed: @current_user.welcomed,
          timezone: tz,
          language: @current_user.language.code,
          is_instructor: @current_user.is_instructor?,
          is_admin: @current_user.is_admin?
        }
      end
    end
  end

  def user_courses
    resp = current_user.rosters.enrolled.includes( :course ).collect do | roster |
      course = roster.course
      {
        id: course.id,
        number: course.number,
        name: course.name,
        bingo_data: current_user.get_bingo_data( course_id: course.id ),
        bingo_performance: current_user.get_bingo_performance( course_id: course.id ),
        experience_performance: current_user.get_experience_performance( course_id: course.id ),
        assessment_performance: current_user.get_assessment_performance( course_id: course.id )
      }
    end
    respond_to do | format |
      format.json { render json: resp }
    end
  end

  def user_activities
    anon = current_user.anonymize?
    resp = current_user.activity_history.collect do | activity |
      {
        id: activity.id,
        type: activity.type,
        course_name: activity.course.get_name( anon ),
        course_number: activity.course.get_number( anon ),
        name: activity.get_name( anon ),
        close_date: activity.end_date,
        performance: case activity.type
                     when 'Terms List'
                       activity.candidate_list_for_user( current_user ).performance
                     when 'Project'
                       current_user.get_assessment_performance( course_id: activity.course.id )
                     when 'Group Experience'
                       current_user.get_experience_performance( course_id: activity.course.id )
                     end,
        other: case activity.type
               when 'Terms List'
                 activity.candidate_list_for_user( current_user ).status
               when 'Project'
                 activity.get_performance( current_user )
               when 'Group Experience'
                 activity.get_user_reaction( current_user ).status
               when 'Assignment'
                 activity.get_submissions_for_user( current_user ).size
               end,
        link: case activity.type
              when 'Terms List', 'Assignment'
                "#{activity.get_link}/#{activity.id}"
              when 'Project', 'Group Experience'
                nil
              end
      }
    end
    respond_to do | format |
      format.json { render json: resp }
    end
  end

  def states_for_country
    country_code = params[:country_code]
    country = HomeCountry.find_by( code: country_code )

    @states = country.nil? ? [] : country.home_states

    # Return the retrieved data
    respond_to do | format |
      format.json do
        render json: @states.collect { | state |
          {
            id: state.id,
            name: state.name,
            code: state.code,
            countryCode: state.home_country_id
          }
        }
      end
    end
  end

  def check_diversity_score
    emails = params[:emails]
    users = User.joins( :emails ).where( emails: { email: emails.split( /[\s,]+/ ) } )
                .includes( :gender, :primary_language,
                           :cip_code, home_state: [:home_country],
                                      reactions: [narrative: [:scenario]] )
    diversity_score = Group.calc_diversity_score_for_group( users: )
    found_users = users.collect do | u |
      { email: u.email,
        name: u.informal_name( false ),
        family_name: u.last_name,
        given_name: u.first_name }
    end
    # Return the retrieved data
    respond_to do | format |
      format.json do
        render json: {
          found_users:,
          diversity_score:
        }
      end
    end
  end

  # Data transport class
  class Event_
    attr_accessor :id, :name, :task_link, :task_name_post, :type, :status, :group_name, :course_name, :start_date,
                  :close_date, :instructor_task, :next_date, :link
  end

  def demo_start
    if current_user.nil?
      current_user = User.new( first_name: t( :demo_surname_1 ),
                               last_name: t( :demo_fam_name_1 ),
                               timezone: t( :demo_user_tz ) )
    end

    e = Event_.new
    e.id = -42
    e.name = t( :demo_group )
    e.task_name_post = "<br>(#{t :project}: #{t( :demo_project )})"
    e.type = :assessment
    e.status = 0
    e.group_name = t( :demo_group )
    e.course_name = t( :demo_course_name )
    e.start_date = 1.day.ago
    e.close_date = 3.days.from_now.end_of_day
    e.next_date = 1.day.ago
    e.link = "project/checkin/#{e.id}"
    e.instructor_task = false

    @events = [e]
    e = Event_.new
    e.id = -11
    e.name =  t( 'candidate_lists.demo_topic' ) 
    e.task_link = terms_demo_entry_path( -1 )
    e.task_name_post = ''
    e.type = :bingo_game
    e.status = 50
    e.group_name = t( :demo_group )
    e.course_name = t( :demo_course_name )
    e.start_date = 1.week.ago
    e.close_date = 4.days.from_now.end_of_day
    e.next_date = e.close_date
    e.link = "bingo/enter_candidates/#{e.id}"
    e.instructor_task = false
    @events << e

    e = Event_.new
    e.id = -77
    e.name = t( 'candidate_lists.demo_review_topic' )
    e.task_link = bingo_demo_review_path( -1 )
    e.task_name_post = ''
    e.type = :bingo_game
    e.status = 0
    e.group_name = t( :demo_group )
    e.course_name = t( :demo_course_name )
    e.start_date = 3.weeks.ago
    e.close_date = Time.zone.today.end_of_day
    e.next_date = e.close_date
    e.link = "bingo/review_candidates/#{e.id}"
    e.instructor_task = true
    # TODO: Enable the candidate review demo
    @events << e

    e = Event_.new
    e.id = -88
    e.name = t( 'candidate_lists.demo_bingo_topic' )
    e.task_link = bingo_demo_play_path
    e.task_name_post = ''
    e.type = :bingo_game
    e.status = -1
    e.group_name = t( :demo_group )
    e.course_name = t( :demo_course_name )
    e.start_date = 2.weeks.ago
    e.close_date = 1.day.from_now.end_of_day
    e.next_date = e.close_date
    e.link = "bingo/candidate_results/#{e.id}"
    e.instructor_task = false
    @events << e

    # Let's output this to JSON
    resp_hash = {
      tasks: @events,
      current_user:,
      consent_logs: {}
    }
    respond_to do | format |
      format.json do
        render json: resp_hash
      end
    end
  end

  private

  def profile_params
    params.require( :user ).permit(
      :first_name, :last_name,
      :timezone, :language_id, :theme, :researcher,
      :gender_id, :date_of_birth, :primary_language_id, :country, :home_state_id,
      :school_id, :cip_code_id, :started_school,
      :impairment_visual, :impairment_auditory, :impairment_cognitive, :impairment_motor, :impairment_other
    )
  end
end
