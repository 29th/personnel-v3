Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root 'home#landing'

  forums_base_url = ENV.fetch('FORUMS_BASE_URL', '')
  sign_in_url = forums_base_url + '/entry/signin'
  sign_out_url = forums_base_url + '/entry/signout'

  get '/signin' => redirect(sign_in_url), :as => :new_user_session
  get '/signout' => redirect(sign_out_url), :as => :destroy_user_session

  get '/about' => 'home#about'
  get '/about/awards' => 'home#awards'
  get '/about/realism' => 'home#realism'
  get '/about/ranks' => 'home#ranks'
  get '/about/historical' => 'home#historical'
  get '/about/server' => 'home#server_rules'
  get '/about/faq' => 'home#faq'
  get '/about/record' => 'home#record'
  get '/about/ourhistory' => 'home#our_history'
  get '/contact' => 'home#contact'
  get '/donate' => 'home#donate'
  get '/servers' => 'home#servers'
  get '/enlist' => 'home#enlist'

  resources :passes
end
