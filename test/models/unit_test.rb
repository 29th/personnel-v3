require "test_helper"

class UnitTest < ActiveSupport::TestCase
  test "invalid without required fields" do
    required_fields = %i[name abbr classification]
    required_fields.each do |field|
      unit = build(:unit, field => nil)
      refute unit.valid?
    end
  end

  test "abbr cannot be longer than 12 chars" do
    unit = build(:unit, abbr: Faker::String.random(length: 13))
    refute unit.valid?
  end

  test "slogan cannot be longer than 140 chars" do
    unit = build(:unit, slogan: Faker::String.random(length: 141))
    refute unit.valid?
  end

  test "end_assignments ends active assignments" do
    unit = create(:unit)
    active_assignments = [
      create(:assignment, unit: unit),
      create(:assignment, unit: unit)
    ]
    inactive_assignment = create(:assignment, unit: unit, end_date: Date.yesterday)

    unit.end_assignments

    active_assignments.each do |assignment|
      assignment.reload
      assert_equal Date.today, assignment.end_date
    end

    assert_equal Date.yesterday, inactive_assignment.end_date
  end
end
