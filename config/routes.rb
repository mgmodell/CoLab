# frozen_string_literal: true
Rails.application.routes.draw do
  get 'admin' => 'courses#index'

  scope 'admin' do
    get 'courses/copy' => 'courses#new_from_template',
        as: :copy_course
    get 'courses/add_students' => 'courses#add_students',
        as: :add_students
    get 'courses/add_instructors' => 'courses#add_instructors',
        as: :add_instructors
    get 'courses/re_invite_student/:user_id' => 'courses#re_invite_student',
        as: :re_invite_student
    get 'projects/add_group' => 'projects#add_group', as: :add_group
    get 'projects/remove_group' => 'projects#remove_group', as: :remove_group
    get 'projects/activate/:id' => 'projects#activate', as: :activate_project
    get 'projects/rescore_group/:id/:group_id' => 'projects#rescore_group', 
        as: :rescore_group
    get 'projects/rescore_groups/:id' => 'projects#rescore_groups', 
        as: :rescore_groups
    get 'experiences/activate/:experience_id' => 'experiences#activate', 
        as: :activate_experience
    get 'bingo_games/activate/:bingo_game_id' => 'bingo_games#activate', 
        as: :activate_bingo_game
    resources :courses, :projects, :experiences, :bingo_games, :schools,
              :consent_forms
    resources :concepts, except: [:destroy, :create]
  end

  scope 'bingo' do
    resources :candidate_lists, only: [:create, :edit, :update, :show]
    get 'request_collaboration/:id/:desired' => 'candidate_lists#request_collaboration',
        as: :request_bingo_collaboration
    get 'candidates_review/:id' => 'bingo_games#review_candidates',
        as: :review_bingo_candidates
    patch 'candidates_review/:id' => 'bingo_games#update_review_candidates',
        as: :update_bingo_candidates_review,
        constraints: ->(req) { req.format == :json }
    get 'list_stats/:id' => 'candidate_lists#list_stats', as: :'bingo_list_stats'
    get 'results/:id' => 'bingo_games#game_results', as: 'game_results',
        constraints: ->(req) { req.format == :json }

    #Gameplay functions
    resources :bingo_boards, only: [:index, :show]
    patch 'bingo_board/:bingo_game_id' => 'bingo_boards#update',
        as: 'update_board'
    get 'bingo_board/:bingo_game_id' => 'bingo_boards#board_for_game',
        as: 'board_for_game'
    get 'concepts_for_game/:id' => 'concepts#concepts_for_game',
        as: :bingo_concepts,
        constraints: ->(req) { req.format == :json }
    get 'worksheet/:bingo_game_id' => 'bingo_boards#worksheet_for_game',
        as: :worksheet_for_bingo
  end

  scope 'infra' do
    post 'quote' => 'home#get_quote', as: :get_quote
    get 'states_for_country/:country_code' => 'home#states_for_country', as: :states_for
    get 'diversity_score_for' => 'home#check_diversity_score',
        as: :check_diversity_score
    get 'locales/:lang/:ns' => 'locales#get_resources', as: :i18n,
        constraints: ->(req) { req.format == :json }
  end

  get 'experiences/next/:experience_id:' => 'experiences#next', as: :next_experience
  get 'exeriences/diagnose' => 'experiences#diagnose', as: :diagnose
  get 'exeriences/reaction' => 'experiences#react', as: :react

  get 'course/accept/:roster_id' => 'courses#accept_roster', as: :accept_roster
  get 'course/decline/:roster_id' => 'courses#decline_roster', as: :decline_roster
  get 'courses/drop_student/:roster_id' => 'courses#drop_student', as: :drop_student
  get 'courses/remove_instructor/:roster_id' => 'courses#remove_instructor',
      as: :remove_instructor

  devise_for :users, controllers:
    { omniauth_callbacks: 'users/omniauth_callbacks',
      registrations: 'registrations' }

  as :user do
    get 'users/remove_email/:email_id', to: 'registrations#remove_email',
      as: :remove_registered_email
    get 'users/set_primary_email/:email_id', to: 'registrations#set_primary_email',
      as: :set_primary_registered_email
    post 'users/add_email', to: 'registrations#add_email', as: :add_registered_email
    get 'users/password/send_reset', to: 'registrations#initiate_password_reset',
      as: :initiate_password_reset
  end

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root to: 'home#index'

  # Consent log paths
  get 'consent_logs/edit/:consent_form_id' => 'consent_logs#edit', as: :edit_consent_log
  patch 'consent_logs/:id' => 'consent_logs#update', as: :consent_log

  scope 'demo' do
  # Demo paths
    get 'installments/complete' => 'installments#demo_complete', as: :assessment_demo_complete
    get 'candidate_lists/entry' => 'candidate_lists#demo_entry', as: :terms_demo_entry
    get 'candidate_lists/play' => 'candidate_lists#demo_play', as: :bingo_demo_play
    get 'home/start' => 'home#demo_start', as: :demo_start
    get 'bingo_board_demo/:bingo_game_id' => 'bingo_boards#board_for_game_demo',
        as: 'board_for_game_demo'
    patch 'update_board_demo/:bingo_game_id' => 'bingo_boards#update_demo',
        as: 'update_board_demo'
    get 'concepts_for_game_demo/:id' => 'concepts#concepts_for_game_demo',
        as: :bingo_concepts_demo,
        constraints: ->(req) { req.format == :json }
    get 'candidates_review_demo/-11' => 'bingo_games#review_candidates_demo',
        as: :bingo_demo_review
    patch 'candidates_review/-11' => 'bingo_games#demo_update_review_candidates',
        as: :demo_update_bingo_candidates_review,
        constraints: ->(req) { req.format == :json }
    get 'worksheet/-42' => 'bingo_boards#demo_worksheet_for_game',
        as: :worksheet_for_bingo_demo,
        constraints: ->(req) { req.format == :pdf }
  end

  get 'installments/new/:assessment_id/:group_id' => 'installments#new', as: :new_installment
  get 'installments/edit/:assessment_id/:group_id' => 'installments#edit', as: :edit_installment
  resources :installments, only: [:create, :update]

  get 'graphing/index' => 'graphing#index', as: :'graphing'
  get 'graphing/data/:unit_of_analysis/:subject/:project/:for_research/:anonymous' =>
          'graphing#data', as: :graphing_data
  get 'graphing/projects/:for_research/:anonymous' =>
          'graphing#projects', as: :graphing_projects
  get 'graphing/subjects/:unit_of_analysis/:project_id/:for_research/:anonymous' =>
          'graphing#subjects', as: :graphing_subjects

end
