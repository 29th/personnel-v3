require 'test_helper'

class UnitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unit = units(:ap1s1)
  end

  test "should get index" do
    get units_url
    assert_response :success
  end

  test "should get new" do
    sign_in_as users(:ltc_fish)
    get new_unit_url
    assert_response :success
  end

  test "should create unit" do
    sign_in_as users(:ltc_fish)
    assert_difference('Unit.count') do
      post units_url, params: { unit: { abbr: @unit.abbr, active: @unit.active, game: @unit.game, name: @unit.name, order: @unit.order, path: @unit.path, timezone: @unit.timezone } }
    end

    assert_redirected_to unit_url(Unit.last)
  end

  test "should show unit" do
    get unit_url(@unit)
    assert_response :success
  end

  test "should get edit" do
    sign_in_as users(:ltc_fish)
    get edit_unit_url(@unit)
    assert_response :success
  end

  test "should update unit" do
    sign_in_as users(:ltc_fish)
    patch unit_url(@unit), params: { unit: { abbr: @unit.abbr, active: @unit.active, game: @unit.game, name: @unit.name, order: @unit.order, path: @unit.path, timezone: @unit.timezone } }
    assert_redirected_to unit_url(@unit)
  end

  test "should destroy unit" do
    skip "constraints prevent unit being deleted"
    sign_in_as users(:ltc_fish)
    assert_difference('Unit.count', -1) do
      delete unit_url(@unit)
    end

    assert_redirected_to units_url
  end
end
