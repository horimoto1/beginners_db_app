Rails.application.routes.draw do
  root "categories#new"
  resources :categories, only: [:show, :new, :create, :edit, :update, :destroy]
end
