class ApplicationController < ActionController::Base
  include Pundit
  helper_method :current_user, :authenticate_user!
  after_action :verify_authorized, unless: :active_admin_controller? # enforce policy for every action

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

end
