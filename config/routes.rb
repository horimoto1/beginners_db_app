Rails.application.routes.draw do
  root "home#top"

  resources :categories, except: :index do
    resources :articles, except: :index
  end

  resources :attachments, only: [:create, :destroy]

  get "*path", to: "application#render_404"
end
