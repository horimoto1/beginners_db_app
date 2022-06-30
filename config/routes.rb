# http://localhost:3000/rails/info/routes

Rails.application.routes.draw do
  root "home#top"

  resources :categories, except: :index do
    resources :articles, except: :index
  end

  resources :attachments, only: [:index, :create, :destroy]

  resources :searches, only: :index

  get "profile", to: "users#show"

  devise_for :users, skip: :all
  devise_scope :user do
    get "login", to: "devise/sessions#new", as: :new_user_session
    post "login", to: "devise/sessions#create", as: :user_session
    delete "logout", to: "devise/sessions#destroy", as: :destroy_user_session
  end
end
