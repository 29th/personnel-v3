require "test_helper"

class PassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "should get index" do
    sign_in_as @user
    get passes_url
    assert_response :success
  end

  test "should show pass" do
    sign_in_as @user
    pass = create(:pass)
    get pass_url(pass)
    assert_response :success
  end
end
