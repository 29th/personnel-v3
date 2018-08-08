Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root 'home#index'

  post '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'

  resources :users
end
