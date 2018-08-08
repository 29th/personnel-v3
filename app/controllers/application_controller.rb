class ApplicationController < ActionController::Base
  include Pundit
  helper_method :current_user
  after_action :verify_authorized, unless: :active_admin_controller? # enforce policy for every action

  private
    def active_admin_controller?
      is_a?(ActiveAdmin::BaseController)
    end

    def current_user
      begin
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      rescue Exception => e
        nil
      end
    end

end
