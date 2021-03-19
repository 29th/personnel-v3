require 'json_web_token'

class ApplicationController < ActionController::Base
  include Pundit
  helper_method :current_user, :authenticate_user!

  # enforce policy for every action
  after_action :verify_authorized, unless: -> { :active_admin_controller? }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected
    def active_admin_controller?
      is_a?(ActiveAdmin::BaseController)
    end

    def authenticate_user!
      redirect_to new_user_session_url unless current_user
    end

    def authenticate_user_for_active_admin!
      redirect_to new_user_session_url unless current_user && active_admin_editor?
    end

    def active_admin_editor?
      # TODO get list of models from ActiveAdmin and iterate them
      policy(Assignment).new? ||
        policy(Award).new? ||
        policy(Pass).new? ||
        policy(Permission).new? ||
        policy(Rank).new? ||
        policy(Server).new? ||
        policy(Unit).new? ||
        policy(UserAward).new? ||
        policy(User).new?
    end

    def current_user
      return @current_user if defined? @current_user

      @current_user = begin
        cookie_name = ENV['FORUMS_COOKIE_NAME']
        token = cookies[cookie_name]
        decoded = JsonWebToken.decode(token)
        forum_member_id = decoded[:sub]
        User.find_by_forum_member_id(forum_member_id)
      rescue JWT::ExpiredSignature, JWT::VerificationError,
             JWT::DecodeError, ActiveRecord::RecordNotFound => e
        nil
      end
    end
  
  private
    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end
end
