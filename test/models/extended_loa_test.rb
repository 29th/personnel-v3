require "test_helper"

class ExtendedLOATest < ActiveSupport::TestCase
  test "active includes eloas with start date in the past and end date in the future" do
    eloa = create(:extended_loa, start_date: 1.day.ago, end_date: 1.day.from_now)
    assert_includes ExtendedLOA.active, eloa
  end

  test "active does not include eloas with end date in the past" do
    eloa = create(:extended_loa, start_date: 1.day.from_now, end_date: 2.days.from_now)
    refute_includes ExtendedLOA.active, eloa
  end

  test "active does not include eloas with return date in the past" do
    eloa = create(:extended_loa, start_date: 1.week.ago, end_date: 1.week.from_now,
                                 return_date: 1.day.ago)
    refute_includes ExtendedLOA.active, eloa
  end

  test "active includes eloas with end date and return date in the future" do
    eloa = create(:extended_loa, start_date: 1.week.ago, end_date: 1.week.from_now,
                                 return_date: 1.day.from_now)
    assert_includes ExtendedLOA.active, eloa
  end

  test "active does not include eloas with start date in the future" do
    eloa = create(:extended_loa, start_date: 1.day.from_now, end_date: 1.week.from_now)
    refute_includes ExtendedLOA.active, eloa
  end

  test "posting date is set automatically" do
    eloa = create(:extended_loa)
    assert_equal Time.zone.now.to_i, eloa.posting_date.to_i
  end
end
