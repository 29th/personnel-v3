require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "nav bar should show sign in link when not logged in" do
    get root_url
    assert_response :success
    assert_select "#user-dropdown", "Sign in"
  end

  test "nav bar should show short name when logged in as a member" do
    user = create(:user, rank_abbr: "Pvt.", last_name: "Foo")
    sign_in_as(user)
    get root_url
    assert_select "#user-dropdown .dropdown-toggle", "Pvt. Foo"
  end

  test "nav bar should show username when logged in as an unregistered user" do
    user = build(:unregistered_user)
    sign_in_as(user)
    get root_url
    assert_select "#user-dropdown .dropdown-toggle", user.forum_member_username
  end

  test "manage pages should only be viewable to someone with manage permission" do
    rifleman = create(:user)
    clerk = create(:user)
    clerk_unit = create(:unit)
    create(:permission, :elevated, abbr: "manage", unit: clerk_unit)
    create(:assignment, :elevated, user: clerk, unit: clerk_unit)

    sign_in_as(rifleman)
    get manage_root_url
    assert_response 302

    sign_in_as(clerk)
    get manage_root_url
    assert_response :success
  end

  test "auth failure should show error to user" do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:discourse] = :invalid_credentials
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:discourse]
    post create_user_session_url(:discourse)
    OmniAuth.config.mock_auth[:discourse] = nil

    follow_redirect!
    assert_redirected_to root_url
    assert_equal "Authentication error: Invalid credentials", flash[:alert]
  end

  test "accessing a private resource when not signed in redirects back unless it's another host" do
    get events_url, headers: {HTTP_REFERER: about_url}
    assert_redirected_to about_url

    get events_url, headers: {HTTP_REFERER: "https://google.com"}
    assert_redirected_to root_url
  end

  test "unregistered users cannot access members-only pages" do
    user = build(:unregistered_user)
    sign_in_as(user)

    get events_url
    assert_response 302

    get manage_root_url
    assert_response 302
  end
end
