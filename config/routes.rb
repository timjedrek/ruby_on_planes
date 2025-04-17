Rails.application.routes.draw do
  get "cities/show"
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
  get "featured-flight-schools", to: "pages#featured_schools", as: :featured_schools
  get "top-rated-flight-schools", to: "pages#top_rated_schools", as: :top_rated_schools

  # User profile section
  resources :user_reviews, only: [ :index ]

  resources :states, only: [ :index, :show ], param: :abbreviation do
    resources :cities, only: [ :show, :new, :create, :edit, :update, :destroy ], param: :name, constraints: { name: /[^\/]+/ } do
      resources :nearby_cities, only: [ :create, :destroy ]
    end
  end
  resources :airports, param: :code do
    resources :schools, only: [ :show, :edit, :update ], param: :id do
      resources :contact_people, only: [ :create, :update, :destroy ]
      resources :reviews, only: [ :new, :create, :edit, :update, :destroy ]
    end
  end

  # Admin routes
  namespace :admin do
    resources :reviews do
      member do
        patch :publish
        patch :unpublish
        patch :verify
        patch :unverify
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
