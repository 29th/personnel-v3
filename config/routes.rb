Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root 'home#index'

  post '/auth/:provider/callback' => 'sessions#create', :as => :create_user_session
  get '/signin' => 'sessions#new', :as => :new_user_session
  get '/signout' => 'sessions#destroy', :as => :destroy_user_session
  get '/auth/failure' => 'sessions#failure'

  resources :passes
  resources :events
end
