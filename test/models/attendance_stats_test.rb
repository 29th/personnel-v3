require "test_helper"

class AttendanceStatsTest < ActiveSupport::TestCase
  class ForUser < AttendanceStatsTest
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

    # I've removed this functionality because it was very expensive to compute
    # this for the stats page and I thought it's better to be consistent
    test "ignores events before a non-honorable discharge" do
      skip
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

  class ForUnit < AttendanceStatsTest
    setup do
      @unit = create(:unit)
    end

    test "calculates 30, 60, 90 days and total" do
      # 0-30 days
      create_attended_event(1.week.ago, attended: 6, absent: 4)
      create_attended_event(2.weeks.ago, attended: 9, absent: 1)

      # 31-60 days
      create_attended_event(6.weeks.ago, attended: 1, absent: 9)
      create_attended_event(7.weeks.ago, attended: 5, absent: 5)

      # 61-90 days
      create_attended_event(9.weeks.ago, attended: 2, absent: 9)
      create_attended_event(10.weeks.ago, attended: 5, absent: 6)
      create_attended_event(11.weeks.ago, attended: 8, absent: 3)

      # 91+ days
      create_attended_event(1.year.ago, attended: 9, absent: 1)

      result = AttendanceStats.for_unit(@unit)

      assert_equal 75, result.last_30_days.round
      assert_equal 53, result.last_60_days.round
      assert_equal 49, result.last_90_days.round
      assert_equal 54, result.total.round
    end

    private

    def create_attended_event(starts_at, attended: 0, absent: 0, mandatory: true)
      event = create(:event, starts_at: starts_at, mandatory: mandatory, unit: @unit)
      create_list(:attendance_record, attended, :attended, event: event)
      create_list(:attendance_record, absent, :absent, event: event)
      event
    end
  end
end
