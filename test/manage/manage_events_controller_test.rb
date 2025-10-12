require "test_helper"

module Manage
  class EventsControllerTest < ActionDispatch::IntegrationTest
    setup do
      user = create(:user)
      unit = create(:unit)
      server = create(:server)
      create(:permission, :elevated, abbr: "manage", unit: unit)
      create(:permission, :elevated, abbr: "event_add", unit: unit)
      create(:assignment, :elevated, user: user, unit: unit)
      sign_in_as user

      @event = build(:event, unit: unit, server: server)
    end

    test "should create one event" do
      assert_difference("Event.count", 1) do
        post manage_events_url, params: {
          event: {
            bulk_dates: 1.day.from_now.strftime("%F"),
            time: "18:00",
            time_zone: @event.time_zone,
            unit_id: @event.unit_id,
            type: @event.type,
            server_id: @event.server.id,
            mandatory: @event.mandatory
          }
        }
      end

      assert_redirected_to manage_event_url(Event.last)
    end

    test "should create multiple events" do
      dates = [
        1.week.from_now,
        2.weeks.from_now,
        3.weeks.from_now
      ]
      bulk_dates = dates.map { |date| date.strftime("%F") }.join(", ")

      assert_difference("Event.count", dates.size) do
        post manage_events_url, params: {
          event: {
            bulk_dates: bulk_dates,
            time: "18:00",
            time_zone: @event.time_zone,
            unit_id: @event.unit_id,
            type: @event.type,
            server_id: @event.server.id,
            mandatory: @event.mandatory
          }
        }
      end

      assert_redirected_to manage_events_url
    end

    test "should convert time to utc based on time zone attribute" do
      assert_difference("Event.count", 1) do
        post manage_events_url, params: {
          event: {
            bulk_dates: "2022-09-03",
            time: "18:00",
            time_zone: "Eastern Time (US & Canada)",
            unit_id: @event.unit_id,
            type: @event.type,
            server_id: @event.server.id,
            mandatory: @event.mandatory
          }
        }
      end

      new_event = Event.last
      assert_equal Time.parse("2022-09-03 22:00 UTC"), new_event.starts_at.utc
    end

    test "should set datetime to the value of starts_at in eastern time" do
      assert_difference("Event.count", 1) do
        post manage_events_url, params: {
          event: {
            bulk_dates: "2022-09-03",
            time: "18:00",
            time_zone: "London",
            unit_id: @event.unit_id,
            type: @event.type,
            server_id: @event.server.id,
            mandatory: @event.mandatory
          }
        }
      end

      new_event = Event.last
      # Note that rails always treats timestamps in databases as if they're
      # stored in UTC. `datetime` is actually stored in Eastern Time. There's
      # no way to tell rails that, so we pretend it's stored in UTC.
      assert_equal Time.parse("2022-09-03 13:00 UTC"), new_event.datetime
    end

    test "edit form should show starts_at in specified time zone" do
      event = create(:event, unit_id: @event.unit.id,
        starts_at: "2022-09-06 00:00 UTC",
        time_zone: "Eastern Time (US & Canada)")

      get edit_manage_event_url(event)

      assert_response :success
      assert_select "#event_starts_at_local" do |matches|
        value = matches.first.attribute("value").value
        assert_equal "2022-09-05 20:00", value
      end
    end

    test "updating time zone should update starts_at and datetime" do
      event = create(:event, unit_id: @event.unit.id,
        starts_at: "2022-09-06 20:00 EDT",
        time_zone: "Eastern Time (US & Canada)")

      assert_equal Time.parse("2022-09-07 00:00 UTC"), event.starts_at
      assert_equal Time.parse("2022-09-06 20:00 EDT"), event.starts_at_local

      patch manage_event_url(event), params: {
        event: {
          starts_at_local: "2022-09-06 20:00",
          time_zone: "London"
        }
      }

      event.reload

      assert_equal "2022-09-06 20:00".in_time_zone("London"), event.starts_at.utc, "starts_at doesn't match expectation"

      # Rails thinks the legacy datetime column is in UTC
      assert_equal "2022-09-06 15:00".in_time_zone("UTC"), event.datetime, "legacy datetime column doesn't match expectation"
    end

    test "should fail and show errors if invalid" do
      assert_difference("Event.count", 0) do
        post manage_events_url, params: {
          event: {
            bulk_dates: 1.day.from_now.strftime("%F"),
            time: "18:00",
            time_zone: @event.time_zone,
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
        post manage_events_url, params: {
          event: {
            bulk_dates: 1.day.from_now.strftime("%F"),
            time: "18:00",
            time_zone: @event.time_zone,
            unit_id: other_unit.id,
            type: @event.type,
            server_id: @event.server.id,
            mandatory: @event.mandatory
          }
        }, headers: {HTTP_REFERER: new_manage_event_url}
      end

      assert_redirected_to new_manage_event_url
    end

    test "should create 20 events maximum" do
      bulk_dates = (Date.today..21.days.from_now)
        .map { |date| date.strftime("%F") }
        .join(", ")

      assert_difference("Event.count", 20) do
        post manage_events_url, params: {
          event: {
            bulk_dates: bulk_dates,
            time: "18:00",
            time_zone: @event.time_zone,
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
        post manage_events_url, params: {
          event: {
            bulk_dates: bulk_dates,
            time: "18:00",
            time_zone: @event.time_zone,
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
        post manage_events_url, params: {
          event: {
            bulk_dates: "",
            time: "",
            time_zone: "",
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
end
