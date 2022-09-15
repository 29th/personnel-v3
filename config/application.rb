require_relative "boot"
ENV["RANSACK_FORM_BUILDER"] = "::SimpleForm::FormBuilder"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Personnel
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.homepage = config_for(:homepage)

    endpoints_config_path = Rails.root.join("config", "endpoints", "#{Rails.env}.yml")
    config.endpoints = config_for(endpoints_config_path)

    config.active_job.queue_adapter = :delayed_job

    config.time_zone = "Eastern Time (US & Canada)"
    config.beginning_of_week = :sunday
  end
end
