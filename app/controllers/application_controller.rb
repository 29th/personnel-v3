class ApplicationController < ActionController::Base
  include Pundit
  helper_method :current_user
  after_action :verify_authorized # enforce policy for every action

  private
    def current_user
      begin
        @current_user ||= User.find(session[:user_id]) if session[:user_id]
      rescue Exception => e
        nil
      end
    end

end
