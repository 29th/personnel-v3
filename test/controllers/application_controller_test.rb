require 'test_helper'
require 'json_web_token'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "nav bar should show sign in link when not logged in" do
    get root_url
    assert_response :success
    assert_select '#user-dropdown', 'Sign in'
  end

  test "nav bar should show short name when logged in" do
    user = create(:user, rank_abbr: 'Pvt.', last_name: 'Foo')
    sign_in_as(user)
    get root_url
    assert_select '#user-dropdown', /^Pvt\. Foo/
  end
end
