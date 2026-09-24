# frozen_string_literal: true

class HomeController < ApplicationController
  # protect_from_forgery except: [:get_quote]
  skip_before_action :authenticate_user!, only: %i[index lookups endpoints demo_start get_quote]
  include Demoable

  def index; end

  def task_list
    # OPTIMIZATION: Eager load course on rosters to prevent N+1 queries when mapping waiting_rosters
    waiting_tasks = current_user.waiting_student_tasks + current_user.waiting_instructor_tasks
    waiting_consent_logs = current_user.waiting_consent_logs
    waiting_rosters = current_user.rosters.invited_student.includes( :course )

    resp_hash = {
      # REFACTOR: Use shorthand Ruby block formatting and cleaner mapping
      tasks: waiting_tasks.map { | t | t.task_data( current_user: ) },
      consent_logs: waiting_consent_logs.map { | cl | { id: cl.id, consent_form_id: cl.consent_form_id } },
      waiting_rosters: waiting_rosters.map do | r |
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
      format.json { render json: resp_hash }
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
      },
      installment: {
        baseUrl: edit_installments_path( project_id: '' ),
        saveInstallmentUrl: installments_path
      },
      bingo_game: {
        activityDirectorUrl: bingo_director_path( bingo_game_id: '' )
      },
      candidate_list: {
        baseUrl: get_candidate_list_path( bingo_game_id: '' )
      },
      candidate_review: {
        baseUrl: review_bingo_candidates_path( id: '' ),
        reviewSaveUrl: update_bingo_candidates_review_path( id: '' ),
        conceptUrl: bingo_concepts_path( 0 )
      },
      candidate_results: {
        baseUrl: my_results_path( id: '' ),
        boardUrl: board_for_game_path( bingo_game_id: '' ),
        conceptsUrl: bingo_concepts_path( id: '' ),
        worksheetUrl: worksheet_for_bingo_path( bingo_game_id: '' )
      },
      graphing: {
        dataUrl: graphing_data_path,
        subjectsUrl: graphing_subjects_path,
        projectsUrl: graphing_projects_path
      },
      assignment: {
        statusUrl: assignment_status_path( id: '' ),
        submissionUrl: submission_path( id: '' ),
        submissionWithdrawalUrl: submission_withdraw_path( id: '' )
      }
    }

    if user_signed_in?
      ep_hash[:home].merge!(
        courseRegRequestsUrl: course_reg_requests_path,
        courseRegUpdatesUrl: proc_course_reg_requests_path,
        selfRegUrl: self_reg_init_path( id: '' )
      )

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

      # OPTIMIZATION: Memoized current_user roles to prevent repeating method checks
      is_admin = current_user.is_admin?
      is_instructor = current_user.is_instructor?
      is_researcher = current_user.researcher?

      if is_admin || is_instructor || is_researcher
        ep_hash[:user] = {
          directorySearchUrl: directory_search_path,
          viewUserUrl: user_details_path
        }
        if is_admin
          ep_hash[:user].merge!(
            deleteUserUrl: delete_user_path,
            setRoleUrl: set_role_path,
            mergeUsersUrl: merge_users_path
          )
        end
      end

      if is_admin || is_instructor
        ep_hash[:project] = {
          baseUrl: projects_path,
          activateProjectUrl: activate_project_path,
          diversityCheckUrl: check_diversity_score_path,
          groupsUrl: groups_path( id: '' ),
          suggestGroupsUrl: suggest_groups_path( id: '' ),
          diversityRescoreGroup: rescore_group_path( id: '' ),
          diversityRescoreGroups: rescore_groups_path( id: '' ),
          ltiConnectionUrl: project_lti_connection_path( id: '' ),
          ltiGradePushUrl: push_project_lti_grades_path( id: '' )
        }
        ep_hash[:course] = {
          baseUrl: courses_path,
          courseCreateUrl: new_course_path,
          courseUsersUrl: get_users_path( id: '' ),
          scoresUrl: course_scores_path( id: '' ),
          courseCopyUrl: copy_course_path( id: '' )
        }
        ep_hash[:school] = {
          baseUrl: schools_path,
          schoolCreateUrl: new_school_path
        }
        ep_hash[:bingo_game].merge!(
          baseUrl: bingo_games_path,
          gameResultsUrl: game_results_path( id: '' ),
          worksheetResultsUrl: ws_results_path( id: '' ),
          worksheetScoreUrl: ws_score_path( id: '' ),
          ltiConnectionUrl: bingo_game_lti_connection_path( id: '' ),
          ltiGradePushUrl: push_bingo_game_lti_grades_path( id: '' )
        )
        ep_hash[:assignment][:baseUrl] = assignments_path
        ep_hash[:experience_admin] = {
          baseUrl: experiences_path,
          diagnosisUrl: diagnose_path,
          reactionUrl: react_path,
          responseDataUrl: response_data_path( id: '' ),
          ltiConnectionUrl: experience_lti_connection_path( id: '' ),
          ltiGradePushUrl: push_experience_lti_grades_path( id: '' )
        }
        ep_hash[:concept] = { baseUrl: concepts_path }
        ep_hash[:rubric] = { baseUrl: rubrics_path }
        ep_hash[:critique] = {
          baseUrl: assignment_critiques_path( id: '' ),
          showUrl: critique_assignment_path( submission_id: '' ),
          updateUrl: critique_update_path( submission_feedback_id: '' )
        }
        ep_hash[:consent_form] = {
          baseUrl: consent_forms_path,
          consentFormCreateUrl: new_consent_form_path
        }
      end
    end

    resources = {
      logged_in: user_signed_in?,
      endpoints: ep_hash,
      lookups: get_lookups
    }
    resources[:profile] = get_profile_hash if user_signed_in?

    respond_to do | format |
      format.json { render json: resources.as_json }
    end
  end

  def get_lookups
    locale = I18n.locale

    # Cache localized database queries per locale
    behaviors = Rails.cache.fetch( "lookups/behaviors/#{locale}", expires_in: 12.hours ) do
      name_col = Behavior.current_locale_column( :name )
      desc_col = Behavior.current_locale_column( :description )

      Behavior.pluck( :id, name_col, desc_col, :needs_detail ).map do | id, name, description, needs_detail |
        { id:, name:, description:, needs_detail: }
      end
    end

    candidate_feedbacks = Rails.cache.fetch( "lookups/candidate_feedbacks/#{locale}", expires_in: 12.hours ) do
      name_col = CandidateFeedback.current_locale_column( :name )
      def_col  = CandidateFeedback.current_locale_column( :definition )

      CandidateFeedback.pluck( :id, name_col, def_col, :credit,
                               :critique ).map do | id, name, definition, credit, critique |
        { id:, name:, definition:, credit:, critique: }
      end
    end

    cip_codes = Rails.cache.fetch( "lookups/cip_codes/#{locale}", expires_in: 12.hours ) do
      name_col = CipCode.current_locale_column( :name )

      CipCode.pluck( :id, :gov_code, name_col ).map do | id, code, name |
        { id:, code:, name: }
      end
    end

    genders = Rails.cache.fetch( "lookups/genders/#{locale}", expires_in: 12.hours ) do
      name_col = Gender.current_locale_column( :name )

      Gender.pluck( :id, name_col, :code ).map do | id, name, code |
        { id:, name:, code: }
      end
    end

    languages = Rails.cache.fetch( "lookups/languages/#{locale}", expires_in: 12.hours ) do
      name_col = Language.current_locale_column( :name )

      Language.pluck( :id, name_col, :code ).map do | id, name, code |
        { id:, name:, code: }
      end
    end

    {
      behaviors:,
      candidate_feedbacks:,
      cip_codes:,
      genders:,
      languages:,
      countries: HomeCountry.pluck( :id, :name, :code ).map do | id, name, code |
        { id:, name:, code: }
      end,
      timezones: HomeController::TIMEZONES,
      timezone_lookup: HomeController::TIMEZONE_HASH,
      oauth_ids: {
        google: Rails.application.credentials.dig( :google, :client_id )
      },
      schools: School.all.map do | school |
        {
          id: school.id,
          name: school.name,
          timezone: school.timezone,
          user_count: school.users.where( active: true ).distinct.count
        }
      end
    }
  end

  def lookups
    respond_to do | format |
      format.json { render json: get_lookups.as_json }
    end
  end

  def get_profile_hash
    # REMOVED USER.COUNTRY: ensured no country field is fetched, referenced, or included in serialization[cite: 2]
    profile_hash = {
      user: current_user.as_json(
        only: %i[
          id first_name last_name gender_id
          timezone theme school_id language_id
          date_of_birth home_state_id cip_code_id
          primary_language_id started_school researcher
          impairment_visual impairment_auditory
          impairment_motor impairment_cognitive
          impairment_other welcomed
        ]
      )
    }

    # REFACTOR: Consolidated boolean flags
    profile_hash[:user].merge!(
      is_instructor: current_user.is_instructor?,
      is_admin: current_user.is_admin?,
      is_researcher: current_user.is_researcher?,
      name: current_user.name( false ),
      emails: current_user.emails.as_json(
        only: %i[id email primary],
        methods: ['confirmed?']
      )
    )
    profile_hash
  end

  def full_profile
    respond_to do | format |
      format.json { render json: get_profile_hash }
    end
  end

  def update_full_profile
    submitted_params = profile_params.to_h
    submitted_params[:welcomed] = true

    if current_user.update( submitted_params )
      notice = 'Profile successfully updated'
      respond_to do | format |
        response = get_profile_hash
        response[:messages] = { main: notice }
        format.json { render json: response }
      end
    else
      logger.debug current_user.errors.full_messages
      respond_to do | format |
        format.json do
          messages = current_user.errors.to_hash
          messages[:main] = 'Please review the errors below'
          render json: { messages: }
        end
      end
    end
  end

  # TimeZones constant definition
  TIMEZONES ||= ActiveSupport::TimeZone.all.map do | tz |
    {
      name: tz.name,
      stdName: tz.tzinfo.name
    }
  end.freeze

  TIMEZONE_HASH = TIMEZONES.each_with_object( {} ) do | next_tz, tz_hash |
    tz_hash[next_tz[:name]] = next_tz[:stdName]
  end.freeze

  def get_quote
    respond_to do | format |
      format.json { render json: Quote.get_quote }
    end
  end

  def simple_profile
    respond_to do | format |
      format.json do
        # OPTIMIZATION: Used current_user consistently instead of mixing @current_user and current_user[cite: 2]
        tz = ActiveSupport::TimeZone.new( current_user.timezone )&.tzinfo&.name
        render json: {
          id: current_user.id,
          name: current_user.name( false ),
          first_name: current_user.first_name,
          last_name: current_user.last_name,
          theme: current_user.theme,
          welcomed: current_user.welcomed,
          timezone: tz,
          language: current_user.language&.code,
          is_instructor: current_user.is_instructor?,
          is_admin: current_user.is_admin?
        }
      end
    end
  end

  def user_courses
    # OPTIMIZATION: Included course association to eliminate N+1 queries on roster.course[cite: 2]
    resp = current_user.rosters.enrolled.includes( :course ).map do | roster |
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
    # OPTIMIZATION: Eager loaded course relationship on activity history items to prevent N+1 queries[cite: 2]
    activities = current_user.activity_history
    activities = activities.includes( :course ) if activities.respond_to?( :includes )

    resp = activities.map do | activity |
      course_id = activity.course.id
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
                       current_user.get_assessment_performance( course_id: )
                     when 'Group Experience'
                       current_user.get_experience_performance( course_id: )
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

    # REFACTOR: Simplified response mapping
    states = country ? country.home_states.pluck( :id, :name, :code, :home_country_id ) : []

    respond_to do | format |
      format.json do
        render json: states.map { | id, name, code, country_id |
          { id:, name:, code:, countryCode: country_id }
        }
      end
    end
  end

  def check_diversity_score
    emails = params[:emails].to_s.split( /[\s,]+/ )

    # REMOVED USER.COUNTRY: REMOVED home_country from eager loading and diversity check dependencies[cite: 2]
    # OPTIMIZATION: Reduced deep eager-loading costs by selecting specific associations
    users = User.joins( :emails )
                .where( emails: { email: emails } )
                .includes( :gender, :primary_language, :cip_code, :home_state,
                           reactions: [{ narrative: [:scenario] }] )

    diversity_score = Group.calc_diversity_score_for_group( users: )
    found_users = users.map do | u |
      {
        email: u.email,
        name: u.informal_name( false ),
        family_name: u.last_name,
        given_name: u.first_name
      }
    end

    respond_to do | format |
      format.json do
        render json: { found_users:, diversity_score: }
      end
    end
  end

  # Data transport struct (replaces mutable OpenStruct/Class overhead)
  Event_ = Struct.new(
    :id, :name, :task_link, :task_name_post, :type, :status,
    :group_name, :course_name, :start_date, :close_date,
    :instructor_task, :next_date, :link, keyword_init: true
  )

  def demo_start
    user = current_user || User.new(
      first_name: t( :demo_surname_1 ),
      last_name: t( :demo_fam_name_1 ),
      timezone: t( :demo_user_tz )
    )

    demo_assignment = get_demo_student_assignment
    demo_inst_assignment = get_demo_instructor_assignment

    # REFACTOR: Clean, declarative instantiation of demo events
    events = [
      Event_.new(
        id: -42,
        name: t( :demo_group ),
        task_name_post: "<br>(#{t :project}: #{t( :demo_project )})",
        type: :assessment,
        status: 0,
        group_name: t( :demo_group ),
        course_name: t( :demo_course_name ),
        start_date: 1.day.ago,
        close_date: 3.days.from_now.end_of_day,
        next_date: 1.day.ago,
        link: 'project/checkin/-42',
        instructor_task: false
      ),
      Event_.new(
        id: -11,
        name: t( 'candidate_lists.demo_topic' ),
        task_link: terms_demo_entry_path( -1 ),
        task_name_post: '',
        type: :bingo_game,
        status: 50,
        group_name: t( :demo_group ),
        course_name: t( :demo_course_name ),
        start_date: 1.week.ago,
        close_date: 4.days.from_now.end_of_day,
        next_date: 4.days.from_now.end_of_day,
        link: 'bingo/enter_candidates/-11',
        instructor_task: false
      ),
      Event_.new(
        id: -77,
        name: t( 'candidate_lists.demo_review_topic' ),
        task_link: bingo_demo_review_path( -1 ),
        task_name_post: '',
        type: :bingo_game,
        status: 0,
        group_name: t( :demo_group ),
        course_name: t( :demo_course_name ),
        start_date: 3.weeks.ago,
        close_date: Time.zone.today.end_of_day,
        next_date: Time.zone.today.end_of_day,
        link: 'bingo/review_candidates/-77',
        instructor_task: true
      ),
      Event_.new(
        id: -88,
        name: t( 'candidate_lists.demo_bingo_topic' ),
        task_link: bingo_demo_play_path,
        task_name_post: '',
        type: :bingo_game,
        status: -1,
        group_name: t( :demo_group ),
        course_name: t( :demo_course_name ),
        start_date: 2.weeks.ago,
        close_date: 1.day.from_now.end_of_day,
        next_date: 1.day.from_now.end_of_day,
        link: 'bingo/candidate_results/-88',
        instructor_task: false
      ),
      Event_.new(
        id: demo_assignment.id,
        name: demo_assignment.name,
        task_link: bingo_demo_play_path,
        task_name_post: '',
        type: :assignment,
        status: 3,
        group_name: t( :demo_group ),
        course_name: t( :demo_course_name ),
        start_date: demo_assignment.start_date,
        close_date: demo_assignment.end_date,
        next_date: demo_assignment.end_date,
        link: "assignment/#{demo_assignment.id}",
        instructor_task: false
      ),
      Event_.new(
        id: demo_inst_assignment.id,
        name: demo_inst_assignment.name,
        task_link: bingo_demo_play_path,
        task_name_post: '',
        type: :submission,
        status: 3,
        group_name: t( :demo_group ),
        course_name: t( :demo_course_name ),
        start_date: demo_inst_assignment.start_date,
        close_date: demo_inst_assignment.end_date,
        next_date: demo_inst_assignment.end_date,
        link: "assignment/critiques/#{demo_inst_assignment.id}",
        instructor_task: true
      )
    ]

    resp_hash = {
      tasks: events,
      current_user: user,
      consent_logs: {}
    }

    respond_to do | format |
      format.json { render json: resp_hash }
    end
  end

  private

  # REMOVED USER.COUNTRY: Removed any permitted parameters for country or country_id[cite: 2]
  def profile_params
    params.require( :user ).permit(
      :first_name, :last_name,
      :timezone, :language_id, :theme, :researcher,
      :gender_id, :date_of_birth, :primary_language_id, :home_state_id,
      :school_id, :cip_code_id, :started_school,
      :impairment_visual, :impairment_auditory, :impairment_cognitive, :impairment_motor, :impairment_other
    )
  end
end
