require 'json_web_token'

class ApplicationController < ActionController::Base
  include Pundit
  helper_method :current_user, :authenticate_user!

  # enforce policy for every action
  after_action :verify_authorized,
               unless: -> { :active_admin_controller? || :high_voltage_controller? }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected
    def active_admin_controller?
      is_a?(ActiveAdmin::BaseController)
    end

    def high_voltage_controller?
      is_a?(HighVoltage::PagesController)
    end

    def authenticate_user!
      redirect_to new_user_session_url unless current_user
    end

    def current_user
      return @current_user if defined? @current_user

      @current_user = begin
        cookie_name = ENV['VANILLA_COOKIE_NAME']
        token = cookies[cookie_name]
        decoded = JsonWebToken.decode(token)
        forum_member_id = decoded[:sub]
        User.find_by_forum_member_id(forum_member_id)
      rescue JWT::ExpiredSignature, JWT::VerificationError,
             JWT::DecodeError, JWT::VerificationError,
             ActiveRecord::RecordNotFound => e
        nil
      end
    end
  
  private
    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end
end
