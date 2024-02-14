require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "signing in with discourse sets the matching user in the session" do
    user = create(:user)
    create_list(:user, 3)

    sign_in_as(user)

    assert_equal user.id, session[:user_id]
  end

  test "signing out removes user from session" do
    user = create(:user)

    sign_in_as(user)
    get destroy_user_session_url

    assert_nil session[:user_id]
  end

  test "signing in redirects you to the page you were on" do
    user = create(:user)

    OmniAuth.config.before_callback_phase do |env|
      env["omniauth.origin"] = about_realism_url
    end
    sign_in_as(user)

    assert_redirected_to about_realism_url

    OmniAuth.config.before_callback_phase = nil
  end

  test "signing in won't redirect to another host" do
    user = create(:user)

    OmniAuth.config.before_callback_phase do |env|
      env["omniauth.origin"] = "https://google.com"
    end
    sign_in_as(user)

    assert_redirected_to root_url

    OmniAuth.config.before_callback_phase = nil
  end

  test "signing in as an unregistered user saves discourse info in the session" do
    user = build(:unregistered_user)
    sign_in_as(user)

    assert_nil session[:user_id]

    assert session["omniauth.discourse_data"], "omniauth.discourse_data is not set in session"
    assert_equal user.forum_member_id, session["omniauth.discourse_data"][:uid]
    assert_equal user.forum_member_username, session["omniauth.discourse_data"]["info"]["nickname"]
    assert_match(/Signed in/, flash[:notice])
  end
end
