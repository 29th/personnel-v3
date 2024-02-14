class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create if Rails.env.development? # omniauth developer strategy only
  skip_after_action :verify_authorized # none of these methods require authentication

  def create
    auth = request.env["omniauth.auth"]
    origin = request.env["omniauth.origin"] if is_known_host(request.env["omniauth.origin"])
    reset_session

    if (user = User.find_by_forum_member_id(auth[:uid]))
      session[:user_id] = user.id
    else
      session["omniauth.discourse_data"] = auth.except(:extra)
    end

    redirect_to origin || root_url, notice: "Signed in!"
  end

  def destroy
    reset_session
    redirect_back fallback_location: root_url, allow_other_host: false,
      notice: "Signed out!"
  end

  def failure
    redirect_to root_url, alert: "Authentication error: #{params[:message].humanize}"
  end

  private

  def is_known_host(url)
    return false if !url

    host = URI(url).host
    host == request.host
  end
end
