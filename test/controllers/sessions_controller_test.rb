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
end
