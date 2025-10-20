Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # root-to-www redirect
  if Rails.env.production?
    match "(*any)",
      constraints: {subdomain: ""},
      to: redirect(subdomain: "www"),
      via: :all
  end

  root "home#landing"

  ActiveAdmin.routes(self)
  get "/admin/*path", to: redirect("/manage/%{path}") # Support old /admin links

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
  get "/roster/squad.xml" => "roster#squad_xml"

  scope "/api/webhooks" do
    post "/discourse",
      to: "discourse_webhooks#user_activated",
      as: :discourse_webhook_user_activated,
      constraints: ->(request) { request.headers["X-Discourse-Event"] == "user_activated" }

    post "/discourse",
      to: "discourse_webhooks#user_updated",
      as: :discourse_webhook_user_updated,
      constraints: ->(request) { request.headers["X-Discourse-Event"] == "user_updated" }

    # return 204 for all other events
    post "/discourse",
      to: ->(env) { [204, {}, [""]] },
      as: :discourse_webhooks_unrecognised
  end

  resources :members, controller: :users, as: :users, only: [:show] do
    get "service-record", to: "users#service_record"
    get "attendance", to: "users#attendance"
    get "qualifications", to: "users#qualifications"
    get "recruits", to: "users#recruits"
    get "reprimands", to: "users#reprimands"
    get "extended-loas", to: "users#extended_loas"
  end

  resources :units, only: [:show] do
    get "attendance", to: "units#attendance"
    get "awols", to: "units#awols"
    get "missing-awards", to: "units#missing_awards"
    get "stats", to: "units#stats"
    get "discharges", to: "units#discharges"
    get "recruits", to: "units#recruits"
  end

  resources :passes, only: [:index, :show]
  resources :events, only: [:index, :show] do
    member do
      get "aar", to: "events#edit_aar"
      patch "aar", to: "events#update_aar"
      put "loa", to: "events#loa"
    end
  end

  resources :enlistments, only: [:show, :new, :create]

  constraints PermissionConstraint.new("admin") do
    mount MaintenanceTasks::Engine, at: "/maintenance_tasks"
  end

  # reverse proxy legacy routes
  with_options controller: "reverse_proxy", via: :all, constraints: {path: /.*/} do
    match "awards(/*path)", action: "awards"
    match "bans(/*path)", action: "bans"
    match "coats(/*path)", action: "coats"
    match "darkest-hour-infobank(/*path)", action: "darkest_hour_infobank"
    match "dh(/*path)", action: "dh"
    match "forums(/*path)", action: "forums"
    match "ForumPostImages(/*path)", action: "forum_post_images"
    match "handbook(/*path)", action: "handbook"
    match "images(/*path)", action: "images"
    match "roid(/*path)", action: "roid"
    match "signalcorps(/*path)", action: "signal_corps"
    match "sigs(/*path)", action: "sigs"
    match "stamps(/*path)", action: "stamps"
    match "wiki(/*path)", action: "wiki"
  end
end
