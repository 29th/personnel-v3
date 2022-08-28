class ApplicationController < ActionController::Base
  include Pundit::Authorization
  helper_method :current_user, :authenticate_user!

  # enforce policy for every action
  after_action :verify_authorized, unless: -> { :active_admin_controller? }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action do
    if current_user
      Honeybadger.context({
        user_id: current_user.id,
        user_name: current_user.short_name
      })
    end
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
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_not_authorized(_exception)
    redirect_back fallback_location: root_url, allow_other_host: false,
      alert: "You are not authorized to perform this action." and return
  end
end
