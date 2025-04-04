Rails.application.routes.draw do
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  
  devise_for :users, controllers: { 
    registrations: "users/registrations", 
    confirmations: "users/confirmations", 
    sessions: "users/sessions" 
  }
  root to: "pages#home"
  get "confirmation_pending", to: "pages#confirmation_pending" 
  get "account_confirmed", to: "pages#account_confirmed"

  get "up" => "rails/health#show", as: :rails_health_check
end
