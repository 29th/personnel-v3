require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unit = create(:unit)
    create(:permission, abbr: "event_view_any", unit: @unit)
    create(:permission, abbr: "event_aar", unit: @unit)

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

  # posting an aar should mark users on extended loa as excused. if it doesn't,
  # perhaps because the eloa was created after the aar was posted, we shouldn't
  # hide that from users, as it will be counted against their attendance.
  test "attendance list should show extended loa status if excused, but not if awol" do
    sign_in_as @user
    event = create(:event, unit: @unit)

    user1 = create(:user)
    user2 = create(:user)
    create(:extended_loa, start_date: 1.day.ago, user: user1)
    create(:extended_loa, start_date: 1.day.ago, user: user2)
    create(:attendance_record, attended: false, excused: true, user: user1, event: event)
    create(:attendance_record, attended: false, excused: false, user: user2, event: event)
    get event_url(event)

    assert_select ".attendance li", {count: 2}, "Expected 2 attendees to be listed"
    assert_select ".attendance li span", {text: "Excused", count: 0}, "Expected 0 excused attendees to be listed"
    assert_select ".attendance li span", {text: "Extended LOA", count: 1}, "Expected 1 attendee to be listed as extended loa"
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

  test "aar should ignore users who aren't expected in attendance" do
    sign_in_as @user

    squad = create(:unit, parent: @unit) # use another unit because @unit also expects @user
    event = create(:event, unit: squad)
    unexpected_user = create(:user)
    expected_users = create_list(:user, 3)
    expected_users.each do |user|
      create(:assignment, user: user, unit: squad)
    end

    user_ids = ["", unexpected_user.id] + expected_users.map(&:id)
    params = {event: {user_ids: user_ids.map(&:to_s)}}

    assert_difference("AttendanceRecord.count", 3) do
      patch aar_event_url(event), params: params
    end

    assert_redirected_to event_url(event)
  end

  test "aar should update attendance records that already exist" do
    sign_in_as @user

    squad = create(:unit, parent: @unit)
    event = create(:event, unit: squad)
    assignments = create_list(:assignment, 5, unit: squad)
    users = assignments.map(&:user)
    users.each do |user|
      create(:attendance_record, user: user, event: event)
    end

    user_ids = [""] + users.first(3).map(&:id)
    params = {event: {user_ids: user_ids.map(&:to_s)}}

    assert_difference("AttendanceRecord.count", 0) do
      patch aar_event_url(event), params: params
    end

    get event_url(event)

    assert_select ".attendance li", {count: 5}, "Expected 5 attendees to be listed"
    assert_select ".attendance li span", {text: "AWOL", count: 2}, "Expected 2 AWOL attendees to be listed"
  end

  test "aar shouldn't overwrite whether user is excused" do
    sign_in_as @user

    event = create(:event, unit: @unit)
    create(:attendance_record, user: @user, event: event, excused: true)
    other_user = create(:user)
    create(:assignment, user: other_user, unit: @unit)

    user_ids = ["", other_user.id]
    params = {event: {user_ids: user_ids.map(&:to_s)}}

    patch aar_event_url(event), params: params

    get event_url(event)

    assert_select ".attendance li", {count: 2}, "Expected 2 attendees to be listed"
    assert_select ".attendance li span", {text: "Excused", count: 1}, "Expected 1 excused attendees to be listed"
  end

  test "aar only sets posting date the first time" do
    sign_in_as @user

    event = create(:event, unit: @unit)

    params = {event: {report: "First report", user_ids: []}}
    patch aar_event_url(event), params: params
    event.reload
    initial_posting_date = event.report_posting_date

    travel 1.day

    params = {event: {report: "Second report", user_ids: []}}
    patch aar_event_url(event), params: params
    event.reload

    assert_equal initial_posting_date, event.report_posting_date, "Expected posting date not to change"
  end

  test "aar updates reporter and edit date on subsequent edits" do
    sign_in_as @user

    other_user = create(:user)
    event = create(:event, unit: @unit, report: "First report",
      reporter: other_user, report_posting_date: 1.day.ago)

    params = {event: {report: "Second report", user_ids: []}}
    freeze_time do
      patch aar_event_url(event), params: params
      event.reload

      assert_equal @user, event.reporter, "Expected reporter to be updated"
      assert_equal Time.current, event.report_edit_date, "Expected edit date to be updated"
    end
  end

  test "user on extended loa should be marked as excused" do
    sign_in_as @user

    squad = create(:unit)
    event = create(:event, unit: squad)
    assignments = create_list(:assignment, 2, unit: squad)
    other_users = assignments.map(&:user)
    user_on_leave = create(:user)
    create(:assignment, user: user_on_leave, unit: squad)
    create(:extended_loa, user: user_on_leave, start_date: 1.day.ago)

    user_ids = [""] + other_users.map(&:id)
    params = {event: {user_ids: user_ids.map(&:to_s)}}
    patch aar_event_url(event), params: params

    event.reload
    attendance_record = event.attendance_records.where(user: user_on_leave).first
    assert attendance_record.excused, "Expected user on leave to be excused"
  end
end
