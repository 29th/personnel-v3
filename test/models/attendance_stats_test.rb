require "test_helper"

class AttendanceStatsTest < ActiveSupport::TestCase
  test "calculates 30, 60, 90 days and total" do
    user = create(:user)
    # 0-30 days
    create(:attendance_record, :attended, :mandatory, event_starts_at: 1.week.ago, user: user)
    create(:attendance_record, :attended, :mandatory, event_starts_at: 2.weeks.ago, user: user)

    # 31-60 days
    create(:attendance_record, :mandatory, event_starts_at: 6.weeks.ago, user: user)
    create(:attendance_record, :attended, :mandatory, event_starts_at: 7.weeks.ago, user: user)

    # 61-90 days
    create(:attendance_record, :mandatory, event_starts_at: 9.weeks.ago, user: user)
    create(:attendance_record, :mandatory, event_starts_at: 10.weeks.ago, user: user)
    create(:attendance_record, :attended, :mandatory, event_starts_at: 11.weeks.ago, user: user)

    # 91+ days
    create(:attendance_record, :mandatory, event_starts_at: 1.year.ago, user: user)

    result = AttendanceStats.for_user(user)

    assert_equal 100, result.last_30_days.round
    assert_equal 75, result.last_60_days.round
    assert_equal 57, result.last_90_days.round
    assert_equal 50, result.total.round
  end

  test "ignores events before a non-honorable discharge" do
    user = create(:user)
    create(:attendance_record, :attended, :mandatory, event_starts_at: 1.week.ago, user: user)
    create(:discharge, type: :general, date: 1.month.ago, user: user)
    create(:attendance_record, :mandatory, event_starts_at: 2.months.ago, user: user)

    result = AttendanceStats.for_user(user)

    assert_equal 100, result.last_90_days.round
  end

  test "ignores non-mandatory events" do
    user = create(:user)
    create(:attendance_record, :attended, :mandatory, event_starts_at: 1.week.ago, user: user)
    create(:attendance_record, :attended, event_starts_at: 1.week.ago, user: user)
    create(:attendance_record, :mandatory, event_starts_at: 2.weeks.ago, user: user)
    create(:attendance_record, :attended, event_starts_at: 2.weeks.ago, user: user)

    result = AttendanceStats.for_user(user)

    assert_equal 50, result.last_90_days.round
  end
end
