require "test_helper"

class EnlistmentTest < ActiveSupport::TestCase
  test "serializes previous_units as JSON" do
    previous_units = [{unit: "1st RB", reason: "AWOL"}, {unit: "2nd AD", reason: "AWOL"}]
    enlistment = create(:enlistment, previous_units: previous_units)
    assert_equal JSON.dump(previous_units), enlistment.previous_units_before_type_cast
  end

  test "treats previous_units as an empty array when blank" do
    enlistment = create(:enlistment, previous_units: "")
    assert_equal [], enlistment.previous_units
  end

  test "previous_units is invalid if it's missing fields" do
    previous_units = [{unit: "1st RB"}]
    enlistment = build_stubbed(:enlistment, previous_units: previous_units)
    refute enlistment.valid?
  end

  test "raises if previous_units contains unknown attribute" do
    previous_units = [{unit: "1st RB", reason: "AWOL", foo: "bar"}]
    assert_raises ActiveModel::UnknownAttributeError do
      build_stubbed(:enlistment, previous_units: previous_units)
    end
  end
end
