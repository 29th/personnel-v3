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

  test "strips whitespace from attributes" do
    enlistment = create(:enlistment, ingame_name: " frank ", recruiter: "someone ")
    assert_equal "frank", enlistment.ingame_name
    assert_equal "someone", enlistment.recruiter
  end

  # Tests for with_recruit_result scope
  test "with_recruit_result returns 'Accepted' for basic accepted enlistment" do
    enlistment = create(:enlistment, status: "accepted", date: 1.year.ago)

    result = Enlistment.with_recruit_result.find(enlistment.id)
    assert_equal "Accepted", result.result
  end

  test "with_recruit_result returns 'Graduated' for recruit with combat assignment after enlistment" do
    enlistment = create(:enlistment, status: "accepted", date: 1.year.ago)
    combat_unit = create(:unit, classification: "Combat")
    create(:assignment,
      user: enlistment.user,
      unit: combat_unit,
      position: create(:position),
      start_date: enlistment.date + 1.day)

    result = Enlistment.with_recruit_result.find(enlistment.id)
    assert_equal "Graduated", result.result
  end

  test "with_recruit_result returns 'Promoted' for recruit with promotion above Private after enlistment" do
    enlistment = create(:enlistment, status: "accepted", date: 1.year.ago)
    higher_rank = create(:rank, order: 3, name: "Corporal") # Above Private (order 2)
    create(:promotion,
      user: enlistment.user,
      new_rank: higher_rank,
      date: enlistment.date + 1.day)

    result = Enlistment.with_recruit_result.find(enlistment.id)
    assert_equal "Promoted", result.result
  end

  test "with_recruit_result prioritizes 'Promoted' over 'Graduated'" do
    enlistment = create(:enlistment, status: "accepted", date: 1.year.ago)

    # Add both graduation and promotion
    combat_unit = create(:unit, classification: "Combat")
    create(:assignment,
      user: enlistment.user,
      unit: combat_unit,
      position: create(:position),
      start_date: enlistment.date + 1.day)

    higher_rank = create(:rank, order: 3, name: "Corporal")
    create(:promotion,
      user: enlistment.user,
      new_rank: higher_rank,
      date: enlistment.date + 2.days)

    result = Enlistment.with_recruit_result.find(enlistment.id)
    assert_equal "Promoted", result.result, "Should prioritize Promoted over Graduated"
  end

  test "with_recruit_result ignores promotions to Private or lower ranks" do
    enlistment = create(:enlistment, status: "accepted", date: 1.year.ago)
    private_rank = create(:rank, order: 2, name: "Private") # Equal to Private threshold
    recruit_rank = create(:rank, order: 1, name: "Recruit") # Below Private threshold

    create(:promotion,
      user: enlistment.user,
      new_rank: private_rank,
      date: enlistment.date + 1.day)

    create(:promotion,
      user: enlistment.user,
      new_rank: recruit_rank,
      date: enlistment.date + 2.days)

    result = Enlistment.with_recruit_result.find(enlistment.id)
    assert_equal "Accepted", result.result, "Should ignore promotions to Private (order 2) or lower"
  end

  test "with_recruit_result ignores assignments to non-Combat units" do
    enlistment = create(:enlistment, status: "accepted", date: 1.year.ago)
    training_unit = create(:unit, classification: "Training")
    staff_unit = create(:unit, classification: "Staff")

    create(:assignment,
      user: enlistment.user,
      unit: training_unit,
      position: create(:position),
      start_date: enlistment.date + 1.day)

    create(:assignment,
      user: enlistment.user,
      unit: staff_unit,
      position: create(:position),
      start_date: enlistment.date + 2.days)

    result = Enlistment.with_recruit_result.find(enlistment.id)
    assert_equal "Accepted", result.result, "Should ignore non-Combat unit assignments"
  end

  test "with_recruit_result ignores promotions and assignments before enlistment date" do
    enlistment = create(:enlistment, status: "accepted", date: 1.year.ago)

    # Add promotion and assignment BEFORE enlistment date
    combat_unit = create(:unit, classification: "Combat")
    create(:assignment,
      user: enlistment.user,
      unit: combat_unit,
      position: create(:position),
      start_date: enlistment.date - 1.day)

    higher_rank = create(:rank, order: 3, name: "Corporal")
    create(:promotion,
      user: enlistment.user,
      new_rank: higher_rank,
      date: enlistment.date - 1.day)

    result = Enlistment.with_recruit_result.find(enlistment.id)
    assert_equal "Accepted", result.result, "Should ignore promotions and assignments before enlistment date"
  end

  test "with_recruit_result works with scope chaining" do
    # Create multiple enlistments with different results
    accepted_enlistment = create(:enlistment, status: "accepted", date: 1.year.ago)

    graduated_enlistment = create(:enlistment, status: "accepted", date: 1.year.ago)
    combat_unit = create(:unit, classification: "Combat")
    create(:assignment,
      user: graduated_enlistment.user,
      unit: combat_unit,
      position: create(:position),
      start_date: graduated_enlistment.date + 1.day)

    promoted_enlistment = create(:enlistment, status: "accepted", date: 1.year.ago)
    higher_rank = create(:rank, order: 4, name: "Sergeant")
    create(:promotion,
      user: promoted_enlistment.user,
      new_rank: higher_rank,
      date: promoted_enlistment.date + 1.day)

    results = Enlistment.accepted.with_recruit_result.order(:id)
    assert_equal "Accepted", results.find(accepted_enlistment.id).result
    assert_equal "Graduated", results.find(graduated_enlistment.id).result
    assert_equal "Promoted", results.find(promoted_enlistment.id).result
  end
end
