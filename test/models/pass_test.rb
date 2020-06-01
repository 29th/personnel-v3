require 'test_helper'

class PassTest < ActiveSupport::TestCase
  test "invalid without user" do
    pass = build(:pass, user: nil)
    refute pass.valid?
  end

  test "invalid without author" do
    pass = build(:pass, author: nil)
    refute pass.valid?
  end

  test "end date cannot be before start date" do
    pass = build(:pass, start_date: 1.day.ago, end_date: 2.days.ago)
    refute pass.valid?
  end

  test "invalid without start date" do
    pass = build(:pass, start_date: nil)
    refute pass.valid?
  end

  test "add_date is set automatically" do
    pass = create(:pass)
    assert_equal pass.add_date, Date.current
  end
end
