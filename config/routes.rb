Rails.application.routes.draw do
  devise_for :users

  # Root route
  root 'home#index'

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end