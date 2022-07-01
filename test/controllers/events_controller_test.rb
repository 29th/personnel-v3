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

  test "should show attendance statuses" do
    sign_in_as @user
    event = create(:event, unit: @unit)

    create(:attendance_record, event: event, attended: true)
    create(:attendance_record, event: event, attended: false, excused: true)
    create(:attendance_record, event: event, attended: false, excused: false)
    get event_url(event)

    assert_select ".attendance li", {count: 3}, "Expected 3 attendees to be listed"
    assert_select ".attendance li span", {text: "Excused", count: 1}, "Expected 1 excused attendee to be listed"
    assert_select ".attendance li span", {text: "AWOL", count: 1}, "Expected 1 AWOL attendee to be listed"
  end

  test "should emphasise events user is expected at" do
    sign_in_as @user

    platoon = create(:unit)
    squad = create(:unit, parent: platoon)
    create(:assignment, user: @user, unit: squad)
    other_unit = create(:unit)

    create(:event, unit: platoon)
    create(:event, unit: squad)
    create(:event, unit: other_unit)

    get events_url

    assert_select ".event", {count: 3}, "Expected 3 events"
    assert_select ".expected", {count: 2}, "Expected 2 events to be emphasised"
  end

  test "should indicate user is expected on parent unit event" do
    sign_in_as @user

    platoon = create(:unit)
    squad = create(:unit, parent: platoon)
    create(:permission, abbr: "event_view_any", unit: squad)
    create(:assignment, user: @user, unit: squad)
    platoon_event = create(:event, unit: platoon)

    get event_url(platoon_event)
    assert_response :success

    assert_select ".expectation", text: /You are expected at this event/
  end

  test "should indicate user is not expected on other unit event" do
    sign_in_as @user

    other_unit = create(:unit)
    other_unit_event = create(:event, unit: other_unit)

    get event_url(other_unit_event)
    assert_response :success

    assert_select ".expectation", text: /You are not expected at this event/
  end
end
