require "test_helper"

class PassesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get passes_url
    assert_response :success
  end

  test "should show pass" do
    pass = create(:pass)
    get pass_url(pass)
    assert_response :success
  end
end
