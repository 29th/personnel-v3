require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "invalid without required fields" do
    required_fields = %i[type starts_at unit server]
    required_fields.each do |field|
      event = build(:event, field => nil)
      refute event.valid?, "#{field} is not required"
    end
  end

  test "expected_users includes subtree users" do
    platoon = create(:unit)
    create(:assignment, unit: platoon)
    squad = create(:unit, parent: platoon)
    user = create(:user)
    create(:assignment, user: user, unit: squad)
    event = create(:event, unit: platoon)

    expected_users = event.expected_users

    assert_equal 2, expected_users.size
    assert_includes expected_users, user
  end

  test "expected_users excludes users assigned after the event" do
    unit = create(:unit)
    event = create(:event, starts_at: 2.weeks.ago, unit: unit)
    create_list(:assignment, 3, start_date: 4.weeks.ago, unit: unit)
    new_user = create(:user)
    create(:assignment, start_date: 1.week.ago, user: new_user, unit: unit)

    expected_users = event.expected_users

    assert_equal 3, expected_users.size
    refute_includes expected_users, new_user
  end

  test "expected_users excludes users whose assignment ended before the event" do
    unit = create(:unit)
    event = create(:event, starts_at: 2.weeks.ago, unit: unit)
    create_list(:assignment, 3, start_date: 4.weeks.ago, unit: unit)
    new_user = create(:user)
    create(:assignment, start_date: 4.weeks.ago, end_date: 3.weeks.ago,
      user: new_user, unit: unit)

    expected_users = event.expected_users

    assert_equal 3, expected_users.size
    refute_includes expected_users, new_user
  end

  test "expected_users includes users whose assignment has since ended" do
    unit = create(:unit)
    event = create(:event, starts_at: 2.weeks.ago, unit: unit)
    create_list(:assignment, 3, start_date: 4.weeks.ago, unit: unit)
    subject_user = create(:user)
    create(:assignment, start_date: 4.week.ago, end_date: 1.week.ago, user: subject_user, unit: unit)

    expected_users = event.expected_users

    assert_equal 4, expected_users.size
    assert_includes expected_users, subject_user
  end

  # e.g. training platoons
  test "expected_users works even if unit is inactive" do
    unit = create(:unit, active: false)
    event = create(:event, starts_at: 2.weeks.ago, unit: unit)
    create_list(:assignment, 3, start_date: 3.weeks.ago, end_date: 1.week.ago, unit: unit)

    expected_users = event.expected_users

    assert_equal 3, expected_users.size
  end

  class AttendanceTotalsTest < EventTest
    test "calculates attendance totals" do
      event = create_attended_event(1.week.ago, attended: 6, absent: 4)

      assert_equal 6, event.attendance_totals.total_attended
      assert_equal 10, event.attendance_totals.total_expected
      assert_equal 4, event.attendance_totals.total_absent
    end

    test "an event with no attendance records has no attendance_totals member" do
      event = create(:event)

      assert_nil event.attendance_totals
    end

    test "total_attended and total_absent coalesce to 0" do
      attended_event = create_attended_event(1.week.ago, attended: 1)
      unattended_event = create_attended_event(1.week.ago, absent: 1)

      assert_equal 0, attended_event.attendance_totals.total_absent
      assert_equal 0, unattended_event.attendance_totals.total_attended
    end

    private

    def create_attended_event(starts_at, attended: 0, absent: 0, mandatory: true)
      event = create(:event, starts_at: starts_at, mandatory: mandatory)
      create_list(:attendance_record, attended, :attended, event: event)
      create_list(:attendance_record, absent, :absent, event: event)
      event
    end
  end
end
