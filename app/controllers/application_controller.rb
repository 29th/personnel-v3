class ApplicationController < ActionController::Base
  include Pundit
  helper_method :current_user, :authenticate_user!
  after_action :verify_authorized, unless: :active_admin_controller? # enforce policy for every action

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected
    def active_admin_controller?
      is_a?(ActiveAdmin::BaseController)
    end

    def authenticate_user!
      redirect_to new_user_session_url unless current_user
    end

    def current_user
      begin
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      rescue Exception => e
        nil
      end
    end
  
  private
    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end
end
