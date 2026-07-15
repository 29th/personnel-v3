require "test_helper"

class UnitTest < ActiveSupport::TestCase
  test "invalid without required fields" do
    required_fields = %i[name abbr classification]
    required_fields.each do |field|
      unit = build(:unit, field => nil)
      refute unit.valid?
    end
  end

  test "abbr cannot be longer than 24 chars" do
    unit = build(:unit, abbr: Faker::String.random(length: 25))
    refute unit.valid?
  end

  test "slogan cannot be longer than 140 chars" do
    unit = build(:unit, slogan: Faker::String.random(length: 141))
    refute unit.valid?
  end

  # Slugs determine public URLs; changing them breaks bookmarks and v2 links

  test "combat unit slug comes from abbr with HQ suffixes stripped" do
    company_hq = create(:unit, abbr: "Able Co. HQ", classification: :combat)
    platoon_hq = create(:unit, abbr: "1st Platoon HQ", classification: :combat)

    assert_equal "able", company_hq.slug
    assert_equal "1st-platoon", platoon_hq.slug
  end

  test "staff unit slug comes from name" do
    unit = create(:unit, name: "Lighthouse", abbr: "LH", classification: :staff)

    assert_equal "lighthouse", unit.slug
  end

  test "v2_slug strips Co, HQ, spaces and dots" do
    assert_equal "Able", build(:unit, abbr: "Able Co. HQ").v2_slug
    assert_equal "Bn", build(:unit, abbr: "Bn. HQ").v2_slug
  end

  test "subtree_abbr strips HQ suffix" do
    assert_equal "Charlie Co.", build(:unit, abbr: "Charlie Co. HQ").subtree_abbr
  end

  test "legacy path column follows ancestry changes" do
    parent = create(:unit)
    child = create(:unit, parent: parent)
    assert_equal "/#{parent.id}/", child[:path]

    new_parent = create(:unit)
    child.update!(parent: new_parent)
    assert_equal "/#{new_parent.id}/", child[:path]
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
