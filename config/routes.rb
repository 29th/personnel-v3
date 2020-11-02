Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root 'home#index'

  post '/auth/:provider/callback' => 'sessions#create', :as => :create_user_session
  get '/signin' => 'sessions#new', :as => :new_user_session
  get '/signout' => 'sessions#destroy', :as => :destroy_user_session
  get '/auth/failure' => 'sessions#failure'

  get '/about' => 'pages#about'
  get '/about/awards' => 'pages#awards'
  get '/about/realism' => 'pages#realism'
  get '/about/ranks' => 'pages#ranks'
  get '/about/historical' => 'pages#historical'
  get '/about/server' => 'pages#server'
  get '/about/faq' => 'pages#faq'
  get '/about/record' => 'pages#record'
  get '/about/ourhistory' => 'pages#our_history'
  get '/donate' => 'pages#donate'
  get '/servers' => 'pages#servers'
  get '/enlist' => 'pages#enlist'

  resources :passes
end
