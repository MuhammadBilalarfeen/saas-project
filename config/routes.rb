Rails.application.routes.draw do
  resources :artifacts
  resources :tenants do
    resources :projects
  end
  
  get "members/new"
  get "members/create"
  get "members/index"
  get "members/show"
  devise_for :users, controllers: {
    confirmations: "confirmations"
  }

  root 'home#index'

  resources :members, only: [:new, :create, :index, :show]
  get '/logout', to: 'sessions#destroy', as: :logout
  get "up" => "rails/health#show", as: :rails_health_check
end