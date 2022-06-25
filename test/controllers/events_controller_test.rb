require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unit = create(:unit)
    create(:permission, abbr: "event_view", unit: @unit)

    @user = create(:user)
    create(:assignment, :leader, user: @user, unit: @unit)
  end

  test "should get index" do
    get events_url
    assert_response :success
  end

  test "should show event" do
    sign_in_as @user
    event = create(:event, unit: @unit)
    get event_url(event)
    assert_response :success
  end
end
