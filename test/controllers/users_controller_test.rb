require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:pvt_antelope)
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    sign_in_as users(:ltc_fish)
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    sign_in_as users(:ltc_fish)
    assert_difference('User.count') do
      post users_url, params: { user: { first_name: @user.first_name, last_name: @user.last_name, rank_id: @user.rank_id, steam_id: @user.steam_id } }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    sign_in_as users(:ltc_fish)
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    sign_in_as users(:ltc_fish)
    patch user_url(@user), params: { user: { first_name: @user.first_name, last_name: @user.last_name, rank_id: @user.rank_id, steam_id: @user.steam_id } }
    assert_redirected_to user_url(@user)
  end

  test "should destroy user" do
    sign_in_as users(:ltc_fish)
    assert_difference('User.count', -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
end
