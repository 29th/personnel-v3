class ApplicationController < ActionController::Base
  include Pundit::Authorization
  helper_method :current_user, :authenticate_user!

  around_action :set_time_zone, if: :current_user
  # enforce policy for every action
  after_action :verify_authorized, unless: -> { :active_admin_controller? }

  if Rails.env.development?
    around_action :n_plus_one_detection
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action do
    if current_user
      Honeybadger.context({
        user_id: current_user.id,
        user_name: current_user.short_name
      })
    end
  end

  # Make controller data available to lograge logger. You must
  # still add it to the log payload in the environment config.
  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    payload[:remote_ip] = request.remote_ip
    payload[:user_id] = current_user.try(:id)
  end

  protected

  def active_admin_controller?
    is_a?(ActiveAdmin::BaseController)
  end

  def authenticate_user!
    unless current_user
      redirect_back fallback_location: root_url, allow_other_host: false,
        alert: "You must be signed in to access that page",
        flash: {sign_in_origin: request.url} and return
    end
  end

  def authenticate_user_for_active_admin!
    unless current_user
      redirect_back fallback_location: root_url, allow_other_host: false,
        alert: "You must be signed in to access that page",
        flash: {sign_in_origin: request.url} and return
    end
    unless current_user.active_admin_editor?
      redirect_back fallback_location: root_url, allow_other_host: false,
        alert: "You are not authorized to access this page" and return
    end
  end

  def current_user
    @current_user ||= if session[:user_id]
      User.find(session[:user_id])
    elsif session["omniauth.discourse_data"]
      User.from_sso(session["omniauth.discourse_data"])
    end
  end

  def user_not_authorized(_exception)
    redirect_back fallback_location: root_url, allow_other_host: false,
      alert: "You are not authorized to perform this action." and return
  end

  def set_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def n_plus_one_detection
    Prosopite.scan
    yield
  ensure
    Prosopite.finish
  end
end
