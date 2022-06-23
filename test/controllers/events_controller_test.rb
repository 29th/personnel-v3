require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unit = create(:unit)
    create(:permission, abbr: "event_view", unit: @unit)
    create(:permission, :leader, abbr: "event_add", unit: @unit)

    @user = create(:user)
    create(:assignment, :leader, user: @user, unit: @unit)
  end

  test "should get index" do
    get events_url
    assert_response :success
  end

  test "should get new" do
    sign_in_as @user
    get new_event_url
    assert_response :success
  end

  test "should create event" do
    sign_in_as @user
    event = build(:event, unit: @unit)
    assert_difference("Event.count") do
      post events_url, params: {
        event: {
          datetime: event.datetime,
          mandatory: event.mandatory,
          type: event.type,
          unit_id: event.unit_id
        }
      }
    end

    assert_redirected_to event_url(Event.last)
  end

  test "should show event" do
    sign_in_as @user
    event = create(:event, unit: @unit)
    get event_url(event)
    assert_response :success
  end

  test "should get edit" do
    sign_in_as @user
    event = create(:event, unit: @unit)
    get edit_event_url(event)
    assert_response :success
  end

  test "should update event" do
    sign_in_as @user
    event = create(:event, unit: @unit)
    patch event_url(event), params: {
      event: {
        datetime: event.datetime,
        mandatory: event.mandatory,
        type: event.type,
        unit_id: event.unit_id
      }
    }
    assert_redirected_to event_url(event)
  end

  test "should destroy event" do
    sign_in_as @user
    event = create(:event, unit: @unit)
    assert_difference("Event.count", -1) do
      delete event_url(event)
    end

    assert_redirected_to events_url
  end
end
