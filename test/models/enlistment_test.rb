require "test_helper"

class EnlistmentTest < ActiveSupport::TestCase
  test "serializes previous_units as JSON" do
    previous_units = [{unit: "1st RB"}, {unit: "2nd AD"}]
    enlistment = create(:enlistment, previous_units: previous_units)
    assert_equal JSON.dump(previous_units), enlistment.previous_units_before_type_cast
  end

  test "treats previous_units as an empty array when blank" do
    enlistment = create(:enlistment, previous_units: "")
    assert_equal [], enlistment.previous_units
  end

  test "validates previous_units" do
    previous_units = [{wrong_key: "foo"}]
    enlistment = build_stubbed(:enlistment, previous_units: previous_units)
    refute enlistment.valid?
  end
end
