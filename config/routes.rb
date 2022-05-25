Rails.application.routes.draw do
  root "categories#new"
  resources :categories, only: [:show, :new, :create, :edit, :update, :destroy] do
    resources :articles, only: [:show, :new, :create, :edit, :update, :destroy]
  end
end
