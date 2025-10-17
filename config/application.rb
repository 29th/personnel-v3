require_relative "boot"
ENV["RANSACK_FORM_BUILDER"] = "::SimpleForm::FormBuilder"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Personnel
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks templates])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.homepage = config_for(:homepage)
    config.siblings = config_for(:siblings)

    config.time_zone = "Eastern Time (US & Canada)"
    config.beginning_of_week = :sunday

    # Authorisation is handled by PermissionConstraint in routes.rb instead
    config.mission_control.jobs.http_basic_auth_enabled = false
  end
end
