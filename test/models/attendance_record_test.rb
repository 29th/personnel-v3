require "test_helper"

class AttendanceRecordTest < ActiveSupport::TestCase
  class DischargeableDates < AttendanceRecordTest
    setup do
      @user = create(:user)
    end

    test "returns dischargeable dates" do
      timestamps = [
        Time.zone.local(2025, 1, 1, 20, 0, 0),
        Time.zone.local(2025, 1, 2, 20, 0, 0),
        Time.zone.local(2025, 1, 3, 20, 0, 0),
        Time.zone.local(2025, 3, 1, 20, 0, 0),
      ]

      awols = timestamps.map do |timestamp|
        build(:attendance_record,
          :absent,
          :mandatory,
          event_starts_at: timestamp,
          user: @user)
      end

      expected = [Date.new(2025, 1, 1), Date.new(2025, 1, 2), Date.new(2025, 1, 3)].to_set
      assert_equal expected, AttendanceRecord.dischargeable_dates(awols)
    end

    test "counts awols falling on same date as one" do
      timestamps = [
        Time.zone.local(2025, 1, 1, 20, 0, 0),
        Time.zone.local(2025, 1, 2, 20, 0, 0),
        Time.zone.local(2025, 1, 2, 21, 0, 0), # different time
      ]

      awols = timestamps.map do |timestamp|
        build(:attendance_record,
          :absent,
          :mandatory,
          event_starts_at: timestamp,
          user: @user)
      end

      assert_empty AttendanceRecord.dischargeable_dates(awols)
    end
    
    test "returns all dates falling within period" do
      timestamps = [
        Time.zone.local(2025, 1, 1, 20, 0, 0),
        Time.zone.local(2025, 1, 2, 20, 0, 0),
        Time.zone.local(2025, 1, 3, 20, 0, 0),
        Time.zone.local(2025, 1, 4, 20, 0, 0),
        Time.zone.local(2025, 1, 5, 20, 0, 0),
        Time.zone.local(2025, 2, 6, 20, 0, 0),
      ]

      awols = timestamps.map do |timestamp|
        build(:attendance_record,
          :absent,
          :mandatory,
          event_starts_at: timestamp,
          user: @user)
      end

      expected = [
        Date.new(2025, 1, 1),
        Date.new(2025, 1, 2),
        Date.new(2025, 1, 3),
        Date.new(2025, 1, 4),
        Date.new(2025, 1, 5),
      ].to_set
      assert_equal expected, AttendanceRecord.dischargeable_dates(awols)
    end
    
    test "returns all dates falling within multiple consecutive periods" do
      timestamps = [
        Time.zone.local(2025, 1, 1, 20, 0, 0),
        Time.zone.local(2025, 1, 2, 20, 0, 0),
        Time.zone.local(2025, 1, 3, 20, 0, 0),
        Time.zone.local(2025, 1, 4, 20, 0, 0),
        Time.zone.local(2025, 1, 5, 20, 0, 0),
        Time.zone.local(2025, 2, 1, 20, 0, 0),
        Time.zone.local(2025, 2, 2, 20, 0, 0),
        Time.zone.local(2025, 3, 4, 20, 0, 0),
      ]

      awols = timestamps.map do |timestamp|
        build(:attendance_record,
          :absent,
          :mandatory,
          event_starts_at: timestamp,
          user: @user)
      end

      expected = [
        Date.new(2025, 1, 1),
        Date.new(2025, 1, 2),
        Date.new(2025, 1, 3),
        Date.new(2025, 1, 4),
        Date.new(2025, 1, 5),
        Date.new(2025, 2, 1),
        Date.new(2025, 2, 2),
      ].to_set
      assert_equal expected, AttendanceRecord.dischargeable_dates(awols)
    end
  end
end
