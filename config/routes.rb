Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root 'home#index'

  forums_base_url = ENV.fetch('FORUMS_BASE_URL', '')
  sign_in_url = forums_base_url + '/entry/signin'
  sign_out_url = forums_base_url + '/entry/signout'

  get '/signin' => redirect(sign_in_url), :as => :new_user_session
  get '/signout' => redirect(sign_out_url), :as => :destroy_user_session

  get '/about' => 'pages#about'
  get '/about/awards' => 'pages#awards'
  get '/about/realism' => 'pages#realism'
  get '/about/ranks' => 'pages#ranks'
  get '/about/historical' => 'pages#historical'
  get '/about/server' => 'pages#server_rules'
  get '/about/faq' => 'pages#faq'
  get '/about/record' => 'pages#record'
  get '/about/ourhistory' => 'pages#our_history'
  get '/contact' => 'pages#contact'
  get '/donate' => 'pages#donate'
  get '/servers' => 'pages#servers'
  get '/enlist' => 'pages#enlist'

  resources :passes
end
