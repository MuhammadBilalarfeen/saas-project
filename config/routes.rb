Rails.application.routes.draw do

  resources :user_projects
  resources :artifacts

  
  resources :tenants do
    member do
      patch :update_plan
    end

    resources :projects do
      
      member do
        get :users        
        post :add_user 
        delete :remove_user   
      end
    end
  end


  resources :members, only: [:new, :create, :index, :show]

  devise_for :users, controllers: { registrations: "registrations" }

  get '/plan/edit', to: 'tenants#edit', as: :edit_plan
  get '/logout', to: 'sessions#destroy', as: :logout
  get "up" => "rails/health#show", as: :rails_health_check
  root 'home#index'
end