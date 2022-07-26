require "json_web_token"

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
      redirect_back fallback_location: root_url,
        alert: "You must be signed in to access that page"
    end
  end

  def authenticate_user_for_active_admin!
    unless current_user && active_admin_editor?
      redirect_back fallback_location: root_url,
        alert: "You must be signed in with appropriate access for that page"
    end
  end

  # Checks whether user has :new? permission on any active admin resources
  def active_admin_editor?
    namespace = ActiveAdmin.application.default_namespace
    resources = ActiveAdmin.application.namespaces[namespace].resources
    resource_classes = resources.grep(ActiveAdmin::Resource).map(&:resource_class)
    resource_classes -= [Enlistment]
    resource_classes.any? do |resource_class|
      Pundit.policy(current_user, resource_class)&.new?
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
