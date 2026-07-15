require "test_helper"

class AttendanceRecordTest < ActiveSupport::TestCase
  class Status < AttendanceRecordTest
    test "status is attended when user attended" do
      record = create(:attendance_record, :attended)

      assert_equal :attended, record.status
    end

    test "status is excused when user was excused without an extended LOA" do
      record = create(:attendance_record, :excused)

      assert_equal :excused, record.status
    end

    test "status is extended_loa when user was excused during an active extended LOA" do
      record = create(:attendance_record, :excused, event_starts_at: 1.day.ago)
      create(:extended_loa, user: record.user,
        start_date: 1.week.ago, end_date: 1.week.from_now)

      assert_equal :extended_loa, record.status
    end

    test "status is awol when user missed a mandatory event" do
      record = create(:attendance_record, :absent, :mandatory)

      assert_equal :awol, record.status
    end

    test "status is absent when user missed a non-mandatory event" do
      record = create(:attendance_record, :absent)

      assert_equal :absent, record.status
    end
  end

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
