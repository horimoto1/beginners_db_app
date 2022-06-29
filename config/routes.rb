# == Route Map
#
#                                Prefix Verb   URI Pattern                                                                              Controller#Action
#                                  root GET    /                                                                                        home#top
#                     category_articles POST   /categories/:category_id/articles(.:format)                                              articles#create
#                  new_category_article GET    /categories/:category_id/articles/new(.:format)                                          articles#new
#                 edit_category_article GET    /categories/:category_id/articles/:id/edit(.:format)                                     articles#edit
#                      category_article GET    /categories/:category_id/articles/:id(.:format)                                          articles#show
#                                       PATCH  /categories/:category_id/articles/:id(.:format)                                          articles#update
#                                       PUT    /categories/:category_id/articles/:id(.:format)                                          articles#update
#                                       DELETE /categories/:category_id/articles/:id(.:format)                                          articles#destroy
#                            categories POST   /categories(.:format)                                                                    categories#create
#                          new_category GET    /categories/new(.:format)                                                                categories#new
#                         edit_category GET    /categories/:id/edit(.:format)                                                           categories#edit
#                              category GET    /categories/:id(.:format)                                                                categories#show
#                                       PATCH  /categories/:id(.:format)                                                                categories#update
#                                       PUT    /categories/:id(.:format)                                                                categories#update
#                                       DELETE /categories/:id(.:format)                                                                categories#destroy
#                           attachments GET    /attachments(.:format)                                                                   attachments#index
#                                       POST   /attachments(.:format)                                                                   attachments#create
#                            attachment DELETE /attachments/:id(.:format)                                                               attachments#destroy
#                              searches GET    /searches(.:format)                                                                      searches#index
#                               profile GET    /profile(.:format)                                                                       users#show
#                      new_user_session GET    /login(.:format)                                                                         devise/sessions#new
#                          user_session POST   /login(.:format)                                                                         devise/sessions#create
#                  destroy_user_session DELETE /logout(.:format)                                                                        devise/sessions#destroy
#         rails_postmark_inbound_emails POST   /rails/action_mailbox/postmark/inbound_emails(.:format)                                  action_mailbox/ingresses/postmark/inbound_emails#create
#            rails_relay_inbound_emails POST   /rails/action_mailbox/relay/inbound_emails(.:format)                                     action_mailbox/ingresses/relay/inbound_emails#create
#         rails_sendgrid_inbound_emails POST   /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                  action_mailbox/ingresses/sendgrid/inbound_emails#create
#   rails_mandrill_inbound_health_check GET    /rails/action_mailbox/mandrill/inbound_emails(.:format)                                  action_mailbox/ingresses/mandrill/inbound_emails#health_check
#         rails_mandrill_inbound_emails POST   /rails/action_mailbox/mandrill/inbound_emails(.:format)                                  action_mailbox/ingresses/mandrill/inbound_emails#create
#          rails_mailgun_inbound_emails POST   /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                              action_mailbox/ingresses/mailgun/inbound_emails#create
#        rails_conductor_inbound_emails GET    /rails/conductor/action_mailbox/inbound_emails(.:format)                                 rails/conductor/action_mailbox/inbound_emails#index
#                                       POST   /rails/conductor/action_mailbox/inbound_emails(.:format)                                 rails/conductor/action_mailbox/inbound_emails#create
#     new_rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/new(.:format)                             rails/conductor/action_mailbox/inbound_emails#new
#    edit_rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id/edit(.:format)                        rails/conductor/action_mailbox/inbound_emails#edit
#         rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#show
#                                       PATCH  /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#update
#                                       PUT    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#update
#                                       DELETE /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#destroy
# rails_conductor_inbound_email_reroute POST   /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                      rails/conductor/action_mailbox/reroutes#create
#                    rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#             rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#                    rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#             update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#                  rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

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
