require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subject = create(:user)

    @user = create(:user)
    create(:assignment, user: @user)
  end

  test "should get profile" do
    get user_url(@subject)
    assert_response :success
  end

  test "should get service record" do
    get user_service_record_url(@subject)
    assert_response :success
  end

  test "should get attendance" do
    sign_in_as @user
    get user_attendance_url(@subject)
    assert_response :success
  end

  test "should get qualifications" do
    sign_in_as @user
    get user_qualifications_url(@subject)
    assert_response :success
  end
end
