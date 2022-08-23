require "test_helper"

class Admin::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    user = create(:user)
    unit = create(:unit)
    server = create(:server)
    create(:permission, :elevated, abbr: "event_add", unit: unit)
    create(:assignment, :elevated, user: user, unit: unit)
    sign_in_as user

    @event = build(:event, unit: unit, server: server)
  end

  test "should create one event" do
    assert_difference("Event.count", 1) do
      post admin_events_url, params: {
        event: {
          bulk_dates: 1.day.from_now.strftime("%F"),
          time: "18:00",
          unit_id: @event.unit_id,
          type: @event.type,
          server_id: @event.server.id,
          mandatory: @event.mandatory
        }
      }
    end

    assert_redirected_to admin_event_url(Event.last)
  end

  test "should create multiple events" do
    dates = [
      1.week.from_now,
      2.weeks.from_now,
      3.weeks.from_now
    ]
    bulk_dates = dates.map { |date| date.strftime("%F") }.join(", ")

    assert_difference("Event.count", dates.size) do
      post admin_events_url, params: {
        event: {
          bulk_dates: bulk_dates,
          time: "18:00",
          unit_id: @event.unit_id,
          type: @event.type,
          server_id: @event.server.id,
          mandatory: @event.mandatory
        }
      }
    end

    assert_redirected_to admin_events_url
  end

  test "should fail and show errors if invalid" do
    assert_difference("Event.count", 0) do
      post admin_events_url, params: {
        event: {
          bulk_dates: 1.day.from_now.strftime("%F"),
          time: "18:00",
          unit_id: @event.unit_id,
          type: @event.type,
          server_id: "", # fail validation
          mandatory: @event.mandatory
        }
      }
    end

    assert_response :success
    assert_select ".errors li"
  end

  test "should fail if not authorized" do
    other_unit = create(:unit)
    assert_difference("Event.count", 0) do
      post admin_events_url, params: {
        event: {
          bulk_dates: 1.day.from_now.strftime("%F"),
          time: "18:00",
          unit_id: other_unit.id,
          type: @event.type,
          server_id: @event.server.id,
          mandatory: @event.mandatory
        }
      }
    end

    assert_redirected_to admin_root_url
  end

  test "should create 20 events maximum" do
    bulk_dates = (Date.today..21.days.from_now)
      .map { |date| date.strftime("%F") }
      .join(", ")

    assert_difference("Event.count", 20) do
      post admin_events_url, params: {
        event: {
          bulk_dates: bulk_dates,
          time: "18:00",
          unit_id: @event.unit_id,
          type: @event.type,
          server_id: @event.server.id,
          mandatory: @event.mandatory
        }
      }
    end
  end

  test "should fail on invalid bulk date format" do
    bulk_dates = "foo, bar"
    assert_difference("Event.count", 0) do
      post admin_events_url, params: {
        event: {
          bulk_dates: bulk_dates,
          time: "18:00",
          unit_id: @event.unit_id,
          type: @event.type,
          server_id: @event.server.id,
          mandatory: @event.mandatory
        }
      }
    end
  end

  test "should fail and show errors if form is empty" do
    skip
    assert_difference("Event.count", 0) do
      post admin_events_url, params: {
        event: {
          bulk_dates: "",
          time: "",
          unit_id: "",
          type: "",
          server_id: "",
          mandatory: "0"
        }
      }
    end

    assert_response :success # as opposed to redirection
    assert_select ".errors li"
  end
end
