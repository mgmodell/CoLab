# frozen_string_literal: true

Rails.application.routes.draw do
  resources :criteria
  resources :rubrics
  scope 'api-backend' do
    post 'courses/copy/:id' => 'courses#new_from_template',
         as: :copy_course,
         constraints: ->(req) { req.format == :json }
    put 'courses/add_students' => 'courses#add_students',
        as: :add_students
    put 'courses/add_instructors' => 'courses#add_instructors',
        as: :add_instructors
    get 'courses/re_invite_student/:user_id' => 'courses#re_invite_student',
        as: :re_invite_student
    get 'course/qr/:id', to: 'courses#qr', as: :course_reg_qr
    get 'projects/add_group' => 'projects#add_group', as: :add_group
    get 'projects/remove_group' => 'projects#remove_group', as: :remove_group
    get 'projects/activate' => 'projects#activate', as: :activate_project
    get 'projects/groups/:id' => 'projects#get_groups',
        as: :groups,
        constraints: ->(req) { req.format == :json }
    patch 'projects/groups/:id' => 'projects#set_groups',
          as: :set_groups,
          constraints: ->(req) { req.format == :json }
    post 'projects/rescore_group/:id' => 'projects#rescore_group',
         as: :rescore_group
    post 'projects/rescore_groups/:id' => 'projects#rescore_groups',
         as: :rescore_groups
    get 'experiences/activate/:experience_id' => 'experiences#activate',
        as: :activate_experience
    get 'bingo_games/activate/:bingo_game_id' => 'bingo_games#activate',
        as: :activate_bingo_game
    get 'course/cal/:id' => 'courses#calendar',
        as: :course_cal,
        constraints: ->(req) { req.format == :json }
    get 'course/reg_requests' => 'courses#reg_requests',
        as: :course_reg_requests,
        constraints: ->(req) { req.format == :json }
    patch 'course/proc_reg_requests' => 'courses#proc_reg_requests',
          as: :proc_course_reg_requests,
          constraints: ->(req) { req.format == :json }
    get 'course/scores/:id' => 'courses#score_sheet',
        as: :course_scores,
        constraints: ->(req) { req.format == :csv }

    resources :concepts, except: %i[destroy create]

    resources :consent_forms, :schools, :courses, :experiences, :projects, :bingo_games, except: %i[new create]

    get 'consent_forms/new/' => 'consent_forms#show', as: :new_consent_form
    post 'consent_forms/:school_id' => 'consent_forms#create'

    get 'schools/new/' => 'schools#show', as: :new_school
    post 'schools/:school_id' => 'schools#create'

    get 'courses/new/' => 'courses#show', as: :new_course
    post 'courses/:course_id' => 'courses#create'

    get 'experiences/new/:course_id' => 'experiences#show', as: :new_experience
    post 'experiences/:course_id' => 'experiences#create'

    get 'projects/new/:course_id' => 'projects#show', as: :new_project
    post 'projects/:course_id' => 'projects#create'

    get 'bingo_games/new/:course_id' => 'bingo_games#show', as: :new_bingo_game
    post 'bingo_games/:course_id' => 'bingo_games#create'

    # Candidate List stuff
    get 'candidate_lists/:bingo_game_id' => 'candidate_lists#get_candidate_list',
        as: :get_candidate_list,
        constraints: ->(req) { req.format == :json }
    put 'candidate_lists/:bingo_game_id' => 'candidate_lists#update',
        as: :update_candidate_list,
        constraints: ->(req) { req.format == :json }
    get 'candidate_lists/collaborate/:bingo_game_id/:desired' => 'candidate_lists#request_collaboration',
        as: :request_collaboration,
        constraints: ->(req) { req.format == :json }

    scope 'bingo' do
      resources :candidate_lists, only: %i[create edit update show]
      # TODO: remove the next line
      get 'request_collaboration/:id/:desired' => 'candidate_lists#request_collaboration',
          as: :request_bingo_collaboration
      get 'candidates_review/:id' => 'bingo_games#review_candidates',
          as: :review_bingo_candidates
      patch 'candidates_review/:id' => 'bingo_games#update_review_candidates',
            as: :update_bingo_candidates_review,
            constraints: ->(req) { req.format == :json }
      get 'list_stats/:id' => 'candidate_lists#list_stats',
          as: :bingo_list_stats
      get 'ws_results/:id' => 'bingo_boards#worksheet_results',
          as: 'ws_results'
      post 'ws_score/:id' => 'bingo_boards#score_worksheet',
            as: 'ws_score'
      get 'results/:id' => 'bingo_games#game_results', as: 'game_results',
          constraints: ->(req) { req.format == :json }
      get 'my_results/:id' => 'bingo_games#my_results', as: 'my_results',
          constraints: ->(req) { req.format == :json }

      # Gameplay functions
      resources :bingo_boards, only: %i[index show]
      patch 'bingo_board/:bingo_game_id' => 'bingo_boards#update',
            as: 'update_board'
      get 'bingo_board/:bingo_game_id' => 'bingo_boards#board_for_game',
          as: 'board_for_game'
      get 'concepts_for_game/:id' => 'concepts#concepts_for_game',
          as: :bingo_concepts,
          constraints: ->(req) { req.format == :json }
      get 'worksheet/:bingo_game_id' => 'bingo_boards#worksheet_for_game',
          as: :worksheet_for_bingo,
        constraints: ->(req) { req.format == :pdf }
    end
    get 'experiences/next/:experience_id' => 'experiences#next', as: :next_experience
    patch 'exeriences/diagnose' => 'experiences#diagnose', as: :diagnose
    patch 'exeriences/reaction' => 'experiences#react', as: :react

    get 'course/users/:id' => 'courses#get_users', as: :get_users,
        constraints: ->(req) { req.format == :json }
    get 'experience/reactions/:id' => 'experiences#get_reactions', as: :get_reactions,
        constraints: ->(req) { req.format == :json }
    get 'course/accept/:roster_id' => 'courses#accept_roster', as: :accept_roster
    get 'course/decline/:roster_id' => 'courses#decline_roster', as: :decline_roster
    get 'courses/drop_student/:roster_id' => 'courses#drop_student', as: :drop_student
    get 'courses/remove_instructor/:roster_id' => 'courses#remove_instructor',
        as: :remove_instructor

    get 'task_list' => 'home#task_list', as: :task_list,
        constraints: ->(req) { req.format == :json }

    # self registration
    get 'course/enroll/:id', to: 'courses#self_reg_init', as: :self_reg_init,
                             constraints: ->(req) { req.format == :json }
    post 'course/enroll/:id', to: 'courses#self_reg_confirm', as: :self_reg_confirm,
                              constraints: ->(req) { req.format == :json }

    # Consent log paths
    get 'consent_logs/edit/:consent_form_id' => 'consent_logs#edit', as: :edit_consent_log
    patch 'consent_logs/:id' => 'consent_logs#update', as: :consent_log
  end

  scope 'infra' do
    get 'quote' => 'home#get_quote', as: :get_quote
    get 'states_for_country/:country_code' => 'home#states_for_country', as: :states_for
    get 'lookups' => 'home#lookups', as: :lookups,
        constraints: ->(req) { req.format == :json }
    get 'simple_profile' => 'home#simple_profile', as: :simple_profile,
        constraints: ->(req) { req.format == :json }
    get 'full_profile' => 'home#full_profile', as: :full_profile,
        constraints: ->(req) { req.format == :json }
    patch 'full_profile' => 'home#update_full_profile',
          constraints: ->(req) { req.format == :json }
    get 'user_course_performance' => 'home#user_courses', as: :user_courses,
        constraints: ->(req) { req.format == :json }
    get 'user_activities' => 'home#user_activities', as: :user_activities,
        constraints: ->(req) { req.format == :json }
    get 'user_consents' => 'consent_logs#user_logs', as: :user_consents,
        constraints: ->(req) { req.format == :json }
    post 'diversity_score_for' => 'home#check_diversity_score',
         as: :check_diversity_score
    get 'locales/:ns' => 'locales#get_resources', as: :i18n,
        constraints: ->(req) { req.format == :json }
    get 'endpoints' => 'home#endpoints', as: :endpoints,
        constraints: ->(req) { req.format == :json }
  end

  # token auth routes available at /api/v1/auth
  mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks], controllers:
  {
    # omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions',
    registrations: 'registrations'
  }
  post 'auth/validate', to: 'users/omniauth_callbacks#validate',
                        as: :validation

  as :user do
    get 'users/remove_email/:email_id', to: 'registrations#remove_email',
                                        as: :remove_registered_email
    get 'users/set_primary_email/:email_id', to: 'registrations#set_primary_email',
                                             as: :set_primary_registered_email
    post 'users/add_email', to: 'registrations#add_email', as: :add_registered_email
    post 'users/password/send_reset', to: 'registrations#initiate_password_reset',
                                     as: :initiate_password_reset
    get 'user/password/edit', to: 'home#index', as: :password_edit
    get 'user/logout', to: 'devise/sessions#destroy', as: :logout
    get 'user/confirm', to: 'registrations#confirm', as: :confirm_me
    patch 'auth/password_change', to: 'registrations#password_change',
                                as: 'password_change'
  end

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root to: 'home#index'

  scope 'demo' do
    # get '' => 'home#demo_start'
    scope 'api-backend' do
    # Demo paths
    get 'task_list' => 'home#demo_start', as: :demo_task_list

    get 'installments/edit/:id' => 'installments#demo_complete', as: :assessment_demo_complete
    get 'candidate_lists/:id' => 'candidate_lists#demo_entry', as: :terms_demo_entry
    get 'candidate_lists/play' => 'candidate_lists#demo_play', as: :bingo_demo_play
    get 'bingo/bingo_board/:bingo_game_id' => 'bingo_boards#board_for_game_demo',
        as: 'board_for_game_demo'
    patch 'update_board_demo/:bingo_game_id' => 'bingo_boards#update_demo',
          as: 'update_board_demo'
    get 'bingo/concepts_for_game/:id' => 'concepts#concepts_for_game_demo',
        as: :bingo_concepts_demo,
        constraints: ->(req) { req.format == :json }
    get 'bingo/candidates_review/:id' => 'bingo_games#review_candidates_demo',
        as: :bingo_demo_review
    patch 'candidates_review/-11' => 'bingo_games#demo_update_review_candidates',
          as: :demo_update_bingo_candidates_review,
          constraints: ->(req) { req.format == :json }
    get 'bingo/worksheet/:id' => 'bingo_boards#demo_worksheet_for_game',
        as: :worksheet_for_bingo_demo,
        constraints: ->(req) { req.format == :pdf }
    get 'bingo/my_results/:id' => 'bingo_games#demo_my_results',
        as: 'my_results_demo',
        constraints: ->(req) { req.format == :json }
  end
  end

  get 'installments/edit/:assessment_id' => 'installments#submit_installment', as: :edit_installment

  resources :installments, only: %i[update create]

  get 'graphing/index' => 'graphing#index', as: :graphing
  # Pull the available projects
  post 'graphing/projects' => # /:for_research/:anonymous' =>
          'graphing#projects', as: :graphing_projects
  # Pull the available groups or students
  post 'graphing/subjects' => # /:unit_of_analysis/:project_id/:for_research/:anonymous' =>
          'graphing#subjects', as: :graphing_subjects

  # Pull the data
  post 'graphing/data' => # /:unit_of_analysis/:subject/:project/:for_research/:anonymous' =>
          'graphing#data', as: :graphing_data

  match '*path', to: 'home#index', via: :all
end
