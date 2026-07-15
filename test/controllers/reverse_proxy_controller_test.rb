require "test_helper"

class ReverseProxyControllerTest < ActionDispatch::IntegrationTest
  test "legacy paths are redirected to add a trailing slash" do
    get "/bans"

    assert_response :moved_permanently
    assert_match %r{/bans/$}, response.location
  end

  test "legacy routes redirect without requiring authentication" do
    get "/bans/"

    assert_response :redirect
    assert_match "forums.29th.org", response.location
  end
end
