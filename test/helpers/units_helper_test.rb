require "test_helper"

class UnitsHelperTest < ActionView::TestCase
  setup do
    @award_with_ribbon = create(:award, code: "eib", title: "Expert Infantry Badge")
    # Simulate an award with a ribbon image by stubbing the method
    @award_with_ribbon.define_singleton_method(:ribbon_image) do
      OpenStruct.new(present?: true, url: "/test_ribbon.png")
    end

    @award_without_ribbon = create(:award, code: "m:rifle:dh", title: "Marksman Rifle Badge")
  end

  private

  # Stub the icon helper method
  def icon(style, icon_name)
    "<i class=\"#{style} fa-#{icon_name}\"></i>".html_safe
  end

  class RenderProgressTest < UnitsHelperTest
    test "when achievement is eib, it calls render_basic_progress" do
      progress_data = {notapplicable: 75}
      result = render_progress(:eib, progress_data)

      assert_includes result, "75%"
    end

    test "when achievement is slt, it calls render_basic_progress" do
      progress_data = {notapplicable: :award}
      result = render_progress(:slt, progress_data)

      assert_includes result, "anpdr.gif"
    end

    test "when progress has marksman key, it calls render_weapon_progress" do
      progress_data = {marksman: 45, sharpshooter: 30, expert: 10}
      result = render_progress(:rifle, progress_data)

      assert_includes result, "45%"
      assert_includes result, "45% toward Marksman"
    end
  end

  class RenderBasicProgressTest < UnitsHelperTest
    test "when progress is :award for eib, it displays eib image" do
      result = render_progress(:eib, {notapplicable: :award})

      assert_includes result, "eib.gif"
      assert_includes result, "Expert Infantry Badge"
    end

    test "when progress is :award for slt, it displays slt image" do
      result = render_progress(:slt, {notapplicable: :award})

      assert_includes result, "anpdr.gif"
      assert_includes result, "Army NCO Professional Development Ribbon"
    end

    test "when progress is positive integer, it displays percentage" do
      result = render_progress(:eib, {notapplicable: 75})

      assert_includes result, "75%"
    end

    test "when progress is 0 or invalid, it displays em dash" do
      assert_includes render_progress(:eib, {notapplicable: 0}), "&mdash;"
      assert_includes render_progress(:slt, {notapplicable: -5}), "&mdash;"
      assert_includes render_progress(:eib, {notapplicable: nil}), "&mdash;"
    end
  end

  class RenderWeaponProgressTest < UnitsHelperTest
    test "when user has expert badge, it displays expert badge only" do
      weapon_progress = {marksman: 100, sharpshooter: 100, expert: :award}

      result = render_weapon_progress(weapon_progress)

      assert_includes result, "expert.gif"
      assert_includes result, "Expert"        # Tooltip shows badge title
      refute_includes result, "100%"  # No progress percentages shown
      refute_includes result, " + "   # No next level progress shown
    end

    test "when user has sharpshooter badge, it displays sharpshooter badge and progress toward expert" do
      weapon_progress = {marksman: 100, sharpshooter: :award, expert: 60}

      result = render_weapon_progress(weapon_progress)

      assert_includes result, "sharpshooter.gif"       # Sharpshooter badge
      assert_includes result, " + 60%"                 # Progress toward expert
      assert_includes result, "Sharpshooter + 60% toward Expert" # Tooltip content
    end

    test "when user has sharpshooter badge but no expert progress, it shows badge without progress" do
      weapon_progress = {marksman: 100, sharpshooter: :award, expert: 0}

      result = render_weapon_progress(weapon_progress)

      assert_includes result, "sharpshooter.gif"
      assert_includes result, "Sharpshooter"  # Just the badge title
      refute_includes result, " + "                    # No progress shown
    end

    test "when user has marksman badge, it displays marksman badge and progress toward sharpshooter" do
      weapon_progress = {marksman: :award, sharpshooter: 75, expert: 0}

      result = render_weapon_progress(weapon_progress)

      assert_includes result, "marksman.gif"           # Marksman badge
      assert_includes result, " + 75%"                 # Progress toward sharpshooter
      assert_includes result, "Marksman + 75% toward Sharpshooter" # Tooltip content
    end

    test "when user has marksman badge but no sharpshooter progress, it shows badge without progress" do
      weapon_progress = {marksman: :award, sharpshooter: 0, expert: 0}

      result = render_weapon_progress(weapon_progress)

      assert_includes result, "marksman.gif"
      assert_includes result, "Marksman"      # Just the badge title
      refute_includes result, " + "                    # No progress shown
    end

    test "when user has no badges but has marksman progress, it shows progress toward marksman" do
      weapon_progress = {marksman: 45, sharpshooter: 30, expert: 10}

      result = render_weapon_progress(weapon_progress)

      assert_includes result, "45% toward Marksman"    # Tooltip shows progress info
      refute_includes result, "img"          # No badge shown
      refute_includes result, " + "           # No next level progress shown
    end

    test "when user has no badges and no progress, it displays progress percentage" do
      weapon_progress = {marksman: 0, sharpshooter: 0, expert: 0}

      result = render_weapon_progress(weapon_progress)

      assert_includes result, "0%"
      assert_includes result, "0% toward Marksman"
      refute_includes result, ".gif"
    end
  end

  class UnitTotalSizeTest < UnitsHelperTest
    test "counts direct assignments to a single unit" do
      user1 = create(:user)
      user2 = create(:user)
      unit = create(:unit)

      assignment1 = create(:assignment, user: user1, unit: unit)
      assignment2 = create(:assignment, user: user2, unit: unit)

      assignments = {unit.id => [assignment1, assignment2]}
      unit_tree = {unit => {}}

      result = unit_total_size(unit, unit_tree, assignments)

      assert_equal 2, result
    end

    test "counts users across unit and subunits" do
      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)

      parent_unit = create(:unit)
      child_unit = create(:unit, parent: parent_unit)

      parent_assignment = create(:assignment, user: user1, unit: parent_unit)
      child_assignment1 = create(:assignment, user: user2, unit: child_unit)
      child_assignment2 = create(:assignment, user: user3, unit: child_unit)

      assignments = {
        parent_unit.id => [parent_assignment],
        child_unit.id => [child_assignment1, child_assignment2]
      }
      unit_tree = {parent_unit => {child_unit => {}}}

      result = unit_total_size(parent_unit, unit_tree, assignments)

      assert_equal 3, result
    end

    test "deduplicates users with multiple assignments in same hierarchy" do
      user1 = create(:user)
      user2 = create(:user)

      parent_unit = create(:unit)
      child_unit = create(:unit, parent: parent_unit)

      # user1 has assignments in both parent and child unit
      parent_assignment = create(:assignment, user: user1, unit: parent_unit)
      child_assignment1 = create(:assignment, user: user1, unit: child_unit)
      child_assignment2 = create(:assignment, user: user2, unit: child_unit)

      assignments = {
        parent_unit.id => [parent_assignment],
        child_unit.id => [child_assignment1, child_assignment2]
      }
      unit_tree = {parent_unit => {child_unit => {}}}

      result = unit_total_size(parent_unit, unit_tree, assignments)

      # Should count user1 only once, plus user2 = 2 total
      assert_equal 2, result
    end

    test "handles unit with no assignments" do
      unit = create(:unit)

      assignments = {}
      unit_tree = {unit => {}}

      result = unit_total_size(unit, unit_tree, assignments)

      assert_equal 0, result
    end

    test "handles nested subunit hierarchies" do
      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)

      parent_unit = create(:unit)
      child_unit = create(:unit, parent: parent_unit)
      grandchild_unit = create(:unit, parent: child_unit)

      parent_assignment = create(:assignment, user: user1, unit: parent_unit)
      child_assignment = create(:assignment, user: user2, unit: child_unit)
      grandchild_assignment = create(:assignment, user: user3, unit: grandchild_unit)

      assignments = {
        parent_unit.id => [parent_assignment],
        child_unit.id => [child_assignment],
        grandchild_unit.id => [grandchild_assignment]
      }
      unit_tree = {parent_unit => {child_unit => {grandchild_unit => {}}}}

      result = unit_total_size(parent_unit, unit_tree, assignments)

      assert_equal 3, result
    end
  end
end
