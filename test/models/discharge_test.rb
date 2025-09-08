require "test_helper"

class DischargeTest < ActiveSupport::TestCase
  test "type_abbr returns correct abbreviations" do
    discharge = build_stubbed(:discharge, type: :honorable)
    assert_equal "HD", discharge.type_abbr

    discharge = build_stubbed(:discharge, type: :general)
    assert_equal "GD", discharge.type_abbr

    discharge = build_stubbed(:discharge, type: :dishonorable)
    assert_equal "DD", discharge.type_abbr
  end

  test "non_honorable scope excludes honorable discharges" do
    honorable_discharge = create(:discharge, type: :honorable)
    general_discharge = create(:discharge, type: :general)
    dishonorable_discharge = create(:discharge, type: :dishonorable)

    non_honorable_discharges = Discharge.non_honorable.all
    assert_equal 2, non_honorable_discharges.size
    assert_includes non_honorable_discharges, general_discharge
    assert_includes non_honorable_discharges, dishonorable_discharge
    refute_includes non_honorable_discharges, honorable_discharge
  end

  test "validates presence of required fields" do
    required_fields = %i[user date type reason]
    required_fields.each do |field|
      discharge = build_stubbed(:discharge, field => nil)
      refute discharge.valid?, "#{field} is not required"
      assert_includes discharge.errors[field], "can't be blank"
    end
  end

  class ForUnitTest < DischargeTest
    test "includes discharges only for users currently assigned to the specified unit" do
      unit = create(:unit)
      other_unit = create(:unit)

      # User currently assigned to the unit
      user_in_unit = create(:user)
      create(:assignment, user: user_in_unit, unit: unit, start_date: 1.month.ago, end_date: 1.week.ago)
      discharge_in_unit = create(:discharge, user: user_in_unit, date: 1.week.ago)

      # User currently assigned to other unit
      user_in_other_unit = create(:user)
      create(:assignment, user: user_in_other_unit, unit: other_unit, start_date: 1.month.ago, end_date: 1.week.ago)
      discharge_in_other_unit = create(:discharge, user: user_in_other_unit, date: 1.week.ago)

      discharges = Discharge.for_unit(unit).all
      assert_includes discharges, discharge_in_unit
      refute_includes discharges, discharge_in_other_unit
    end

    test "excludes discharges for users previously assigned to the unit" do
      unit = create(:unit)
      other_unit = create(:unit)

      # User previously assigned to the unit but now in different unit
      user_previously_in_unit = create(:user)
      create(:assignment, user: user_previously_in_unit, unit: unit,
        start_date: 3.months.ago, end_date: 2.months.ago)
      create(:assignment, user: user_previously_in_unit, unit: other_unit,
        start_date: 2.months.ago, end_date: Date.current)
      discharge_previously_in_unit = create(:discharge, user: user_previously_in_unit, date: Date.current)

      discharges = Discharge.for_unit(unit).all
      refute_includes discharges, discharge_previously_in_unit
    end

    test "excludes discharges for users subsequently assigned to the unit" do
      unit_a = create(:unit)
      unit_b = create(:unit)

      # User was discharged while in unit_a, then re-enlisted and assigned to unit_b
      user_subsequently_in_unit = create(:user)
      create(:assignment, user: user_subsequently_in_unit, unit: unit_a,
        start_date: 2.months.ago, end_date: 1.month.ago)

      discharge = create(:discharge, user: user_subsequently_in_unit, date: 1.month.ago)
      # later re-enlisted and assigned to unit_b

      create(:assignment, user: user_subsequently_in_unit, unit: unit_b,
        start_date: 1.week.ago)

      discharges = Discharge.for_unit(unit_b).all
      refute_includes discharges, discharge
    end

    test "includes discharges for user with multiple assignments" do
      unit = create(:unit)
      other_unit = create(:unit)

      # User with multiple assignments to the unit, currently assigned
      user_multiple_assignments = create(:user)
      create(:assignment, user: user_multiple_assignments, unit: unit,
        start_date: 6.months.ago, end_date: Date.current)
      create(:assignment, user: user_multiple_assignments, unit: other_unit,
        start_date: 3.months.ago, end_date: Date.current)
      discharge = create(:discharge, user: user_multiple_assignments, date: Date.current)

      discharges = Discharge.for_unit(unit).all
      assert_includes discharges, discharge
    end

    test "when multiple units specified, includes discharges for users in any of those units" do
      unit1 = create(:unit)
      unit2 = create(:unit)
      other_unit = create(:unit)

      # User in unit1
      user_in_unit1 = create(:user)
      create(:assignment, user: user_in_unit1, unit: unit1, start_date: 1.month.ago, end_date: 1.day.ago)
      discharge_in_unit1 = create(:discharge, user: user_in_unit1, date: 1.day.ago)

      # User in unit2
      user_in_unit2 = create(:user)
      create(:assignment, user: user_in_unit2, unit: unit2, start_date: 1.month.ago, end_date: 2.days.ago)
      discharge_in_unit2 = create(:discharge, user: user_in_unit2, date: 2.days.ago)

      # User in other_unit
      user_in_other_unit = create(:user)
      create(:assignment, user: user_in_other_unit, unit: other_unit, start_date: 1.month.ago, end_date: 3.days.ago)
      discharge_in_other_unit = create(:discharge, user: user_in_other_unit, date: 3.days.ago)

      discharges = Discharge.for_unit([unit1, unit2]).all
      assert_includes discharges, discharge_in_unit1
      assert_includes discharges, discharge_in_unit2
      refute_includes discharges, discharge_in_other_unit
    end
  end
end
