class SessionsController < ApplicationController
  # Steam uses ?_method=post so rails expects an authenticity token
  skip_before_action :verify_authenticity_token, only: :create
  skip_after_action :verify_authorized # none of these methods require authentication

  def new
    redirect_to '/auth/steam'
  end

  def create
    auth = request.env['omniauth.auth']
    user = User.where(:steamid => auth['uid']).first || User.create_with_auth(auth)

    reset_session
    session[:user_id] = user.id
    redirect_to root_url, :notice => 'Signed in!'
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end
end
