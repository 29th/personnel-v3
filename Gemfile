source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").strip

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 8.0.3"
# Use mysql as the database for Active Record
gem "mysql2", ">= 0.4.4", "< 0.6.0"
# Use Puma as the app server
gem "puma", "~> 6.4", ">= 6.4.2"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "debug", ">= 1.0.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "dotenv-rails", groups: [:development, :test]
  gem "standard", "~> 1.0", ">= 1.0.4"
  gem "prosopite"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "awesome_print", "~> 1.9", ">= 1.9.2"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15", "< 4.0"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  # gem 'webdrivers'
  gem "webmock", "~> 3.12", ">= 3.12.1"
  gem "minitest-stub_any_instance", "~> 1.0", ">= 1.0.2"
  gem "mocha", "~> 2.1"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "pundit", "~> 2.1"
gem "bootstrap", "~> 4.6"
gem "kaminari", "~> 1.2", ">= 1.2.1"
gem "activeadmin", "~> 3.3.0"
gem "nilify_blanks", "~> 1.4"
gem "ancestry", "~> 4.3", ">= 4.3.3"
gem "jwt", "~> 2.2", ">= 2.2.2"
gem "validates_timeliness", "~> 8.0"
gem "activeadmin_addons", "~> 1.10", ">= 1.10.1"
gem "simple_form", "~> 5.3"
gem "ransack", "~> 4.1", ">= 4.1.1"
gem "simple_calendar", "~> 2.0"
gem "redcarpet", "~> 3.6", ">= 3.6.0"
gem "shrine", "~> 3.0"
gem "aws-sdk-s3", "~> 1.14", require: false
gem "image_processing", "~> 1.0"
gem "fastimage", "~> 2.2", ">= 2.2.2"
gem "flag-icons-rails", "~> 3.4", ">= 3.4.6.1"
gem "audited", "~> 5.0"
gem "honeybadger", "~> 5.4"
gem "scout_apm", "~> 5.3", ">= 5.3.1"
gem "retryable", "~> 3.0", ">= 3.0.5"
gem "sassc", "~> 2.4"
gem "faraday", "~> 2.5", ">= 2.5.2"
gem "faraday-retry", "~> 2.0"
gem "bb-ruby", "~> 1.4"
gem "active_link_to", "~> 1.0", ">= 1.0.5"
gem "omniauth", "~> 2.1"
gem "omniauth-rails_csrf_protection", "~> 1.0", ">= 1.0.1"
gem "omniauth-discourse", github: "29th/omniauth-discourse"
gem "friendly_id", "~> 5.4", ">= 5.4.2"
gem "data_migrate", "~> 11.3.0"
gem "appsignal", "~> 3.1", ">= 3.1.5"
gem "font-awesome-sass", "~> 6.2.0"
gem "jsbundling-rails", "~> 1.2", ">= 1.2.1"
gem "activeadmin-searchable_select", "~> 1.8"
gem "stimulus-rails", "~> 1.3"
gem "store_model", "~> 4.3.0"
gem "config", "~> 5.1"
gem "rails-reverse-proxy", "~> 0.13.0"
gem "dry-validation", "~> 1.11"
gem "lograge", "~> 0.14.0"
gem "logstash-event", "~> 1.2"
gem "delayed", "~> 1.2"
gem "maintenance_tasks", "~> 2.12"
