Rails.application.routes.draw do
  resources :user_projects
  # Main resources
  resources :artifacts
  resources :tenants do
  resources :projects do
    member do
      get :users
      post :add_user
    end
  end
end
  resources :tenants do
    member do
      patch :update_plan
    end
    resources :projects
  end

  # Members routes
  resources :members, only: [:new, :create, :index, :show]

  # Devise routes with custom controllers
  devise_for :users, controllers: {
    registrations: "registrations"
  }

  # Logout route
  get '/logout', to: 'sessions#destroy', as: :logout

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root 'home#index'

  # Plan edit shortcut
  get '/plan/edit', to: 'tenants#edit', as: :edit_plan
end