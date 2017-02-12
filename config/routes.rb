Rails.application.routes.draw do
  
  get 'admin' => 'courses#index'

  scope 'admin', as: 'admin' do
    resources :courses, :projects, :experiences
    get 'courses/add_students' => 'courses#add_students', :as => 'add_students'
    get 'projects/add_group' => 'projects#add_group', :as => 'add_group'
  end

  get 'exp/next/:experience_id:' => 'exps#next', :as => 'next_experience'
  get 'exp/diagnose' => 'exps#diagnose', :as => 'diagnose'
  get 'exp/reaction' => 'exps#react', :as => 'react'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root to: 'home#index'

  # Consent log paths
  get 'consent_logs/edit/:consent_form_id' => 'consent_logs#edit', :as => 'edit_consent_log'
  patch 'consent_logs/:id' => 'consent_logs#update', :as => 'consent_log'

  get 'installments/new/:assessment_id/:group_id' => 'installments#new', :as => 'new_installment'
  get 'installments/edit/:assessment_id/:group_id' => 'installments#edit', :as => 'edit_installment'
  resources :installments, only: [:create, :update]

  get "graphing/index" => "graphing#index", :as => "graphing"
  get "graphing/data/:unit_of_analysis/:subject/:assessment/:data_processing/:for_research" => "graphing#data", 
    :as => "graphing_data"
  get "graphing/subjects/:unit_of_analysis/:assessment_id/:for_research" => "graphing#subjects",
    :as => "graphing_support"

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
