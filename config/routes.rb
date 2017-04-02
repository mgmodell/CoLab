# frozen_string_literal: true
Rails.application.routes.draw do
  get 'admin' => 'courses#index'

  scope 'admin' do
    get 'courses/add_students' => 'courses#add_students', :as => 'add_students'
    get 'courses/add_instructors' => 'courses#add_instructors', :as => 'add_instructors'
    get 'courses/re_invite_student/:user_id' => 'courses#re_invite_student', :as => 're_invite_student'
    get 'projects/add_group' => 'projects#add_group', :as => 'add_group'
    get 'projects/remove_group' => 'projects#remove_group', :as => 'remove_group'
    get 'projects/activate/:project_id' => 'projects#activate', :as => 'activate_project'
    get 'experiences/activate/:experience_id' => 'experiences#activate', :as => 'activate_experience'
    get 'bingo_games/activate/:bingo_game_id' => 'bingo_games#activate', :as => 'activate_bingo_game'
    resources :courses, :projects, :experiences, :bingo_games
  end

  scope 'bingo' do
    resources :candidate_lists, only: [:edit, :update]
    get 'request_collaboration/:candidate_list_id/:desired' => 'candidate_lists#request_collaboration', :as => 'request_bingo_collaboration'
  end

  get 'experiences/next/:experience_id:' => 'experiences#next', :as => 'next_experience'
  get 'exeriences/diagnose' => 'experiences#diagnose', :as => 'diagnose'
  get 'exeriences/reaction' => 'experiences#react', :as => 'react'

  get 'course/accept/:roster_id' => 'courses#accept_roster', :as => 'accept_roster'
  get 'course/decline/:roster_id' => 'courses#decline_roster', :as => 'decline_roster'
  get 'courses/drop_student/:roster_id' => 'courses#drop_student', :as => 'drop_student'
  get 'courses/remove_instructor/:roster_id' => 'courses#remove_instructor', :as => 'remove_instructor'

  devise_for :users, controllers:
    { omniauth_callbacks: 'users/omniauth_callbacks',
      registrations: 'registrations' }
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root to: 'home#index'

  # Consent log paths
  get 'consent_logs/edit/:consent_form_id' => 'consent_logs#edit', :as => 'edit_consent_log'
  patch 'consent_logs/:id' => 'consent_logs#update', :as => 'consent_log'

  get 'installments/demo_start' => 'installments#demo_start', :as => 'demo_start'
  get 'installments/demo_complete' => 'installments#demo_complete', :as => 'demo_complete'

  get 'installments/new/:assessment_id/:group_id' => 'installments#new', :as => 'new_installment'
  get 'installments/edit/:assessment_id/:group_id' => 'installments#edit', :as => 'edit_installment'
  resources :installments, only: [:create, :update]

  get 'graphing/index' => 'graphing#index', :as => 'graphing'
  get 'graphing/data/:unit_of_analysis/:subject/:project/:data_processing/:for_research' => 'graphing#data',
      :as => 'graphing_data'
  get 'graphing/subjects/:unit_of_analysis/:project_id/:for_research' => 'graphing#subjects',
      :as => 'graphing_support'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
