Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root "home#landing"

  get "/signout", to: "sessions#destroy", as: :destroy_user_session
  match "/auth/:provider/callback", to: "sessions#create", via: [:get, :post], as: :create_user_session
  get "/auth/failure", to: "sessions#failure"

  get "/about" => "home#about"
  get "/about/awards" => "home#awards"
  get "/about/realism" => "home#realism"
  get "/about/ranks" => "home#ranks"
  get "/about/historical" => "home#historical"
  get "/about/server" => "home#server_rules"
  get "/about/faq" => "home#faq"
  get "/about/record" => "home#record"
  get "/about/ourhistory" => "home#our_history"
  get "/contact" => "home#contact"
  get "/donate" => "home#donate"
  get "/servers" => "home#servers"
  get "/enlist" => "home#enlist"

  get "/roster" => "roster#index"

  post "/api/webhooks/discourse" => "discourse_webhooks#receive", :as => :discourse_webhooks

  resources :passes
  resources :events, only: [:index, :show] do
    member do
      get "aar", to: "events#edit_aar"
      patch "aar", to: "events#update_aar"
      put "loa", to: "events#loa"
    end
  end
end
