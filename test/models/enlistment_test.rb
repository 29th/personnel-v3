require "test_helper"

class EnlistmentTest < ActiveSupport::TestCase
  test "serializes previous_units as JSON" do
    previous_units = [
      {unit: "1st RB", game: "DoD", name: "Jo", rank: "Pvt", reason: "AWOL"},
      {unit: "2nd AD", game: "RS", name: "jo", rank: "N/A", reason: "AWOL"}
    ]
    enlistment = create(:enlistment, previous_units: previous_units)
    assert_equal JSON.dump(previous_units), enlistment.previous_units_before_type_cast
  end

  test "treats previous_units as an empty array when nil" do
    enlistment = build_stubbed(:enlistment)
    assert_equal [], enlistment.previous_units
  end

  test "previous_units is invalid if it's missing fields" do
    previous_units = [{unit: "1st RB"}]
    enlistment = build_stubbed(:enlistment, previous_units: previous_units)
    refute enlistment.valid?
  end

  test "previous_units discards unknown attribute" do
    previous_units = [{unit: "1st RB", reason: "AWOL", foo: "bar"}]
    enlistment = build_stubbed(:enlistment, previous_units: previous_units)
    assert enlistment.previous_units.any? { |pu| pu.attributes.has_key?("name") }, "does not have expected name attribute"
    refute enlistment.previous_units.any? { |pu| pu.attributes.has_key?("foo") }, "has foo attribute"
  end

  test "age is invalid if not in known list" do
    enlistment = build_stubbed(:enlistment, age: "12")
    refute enlistment.valid?

    enlistment = build_stubbed(:enlistment, age: "100")
    refute enlistment.valid?
  end

  test "middle_name only saves first character" do
    enlistment = build_stubbed(:enlistment, middle_name: "Anthony")
    assert enlistment.middle_name == "A"
  end
end
