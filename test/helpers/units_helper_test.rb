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
    test "when progress is :award and award has ribbon image, it displays award ribbon" do
      result = render_progress(:award, @award_with_ribbon)

      assert_includes result, "test_ribbon.png"
    end

    test "when progress is :award and award has no ribbon image, it displays check icon" do
      result = render_progress(:award, @award_without_ribbon)

      assert_includes result, "square-check"
    end

    test "when progress is positive integer, it displays percentage" do
      result = render_progress(75, nil)

      assert_includes result, "75%"
    end

    test "when progress is 0 or invalid, it displays em dash" do
      assert_includes render_progress(0, nil), "&mdash;"
      assert_includes render_progress(-5, nil), "&mdash;"
      assert_includes render_progress(nil, nil), "&mdash;"
      assert_includes render_progress("invalid", nil), "&mdash;"
    end
  end

  class RenderWeaponBadgeTest < UnitsHelperTest
    setup do
      @expert_award = create(:award, code: "e:rifle:dh", title: "Expert Rifleman")
      @sharpshooter_award = create(:award, code: "s:rifle:dh", title: "Sharpshooter Rifleman")
      @marksman_award = create(:award, code: "m:rifle:dh", title: "Marksman Rifleman")

      @awards = {
        expert: @expert_award,
        sharpshooter: @sharpshooter_award,
        marksman: @marksman_award
      }
    end

    test "when user has expert badge, it displays expert badge only" do
      weapon_progress = {marksman: 100, sharpshooter: 100, expert: :award}

      result = render_weapon_badge(weapon_progress, @awards)

      assert_includes result, "square-check"
      assert_includes result, "Expert"        # Tooltip shows badge title
      refute_includes result, "100%"  # No progress percentages shown
      refute_includes result, " + "   # No next level progress shown
    end

    test "when user has sharpshooter badge, it displays sharpshooter badge and progress toward expert" do
      weapon_progress = {marksman: 100, sharpshooter: :award, expert: 60}

      result = render_weapon_badge(weapon_progress, @awards)

      assert_includes result, "square-check"           # Sharpshooter badge
      assert_includes result, " + 60%"                 # Progress toward expert
      assert_includes result, "Sharpshooter + 60% toward Expert" # Tooltip content
    end

    test "when user has sharpshooter badge but no expert progress, it shows badge without progress" do
      weapon_progress = {marksman: 100, sharpshooter: :award, expert: 0}

      result = render_weapon_badge(weapon_progress, @awards)

      assert_includes result, "square-check"
      assert_includes result, "Sharpshooter"  # Just the badge title
      refute_includes result, " + "                    # No progress shown
    end

    test "when user has marksman badge, it displays marksman badge and progress toward sharpshooter" do
      weapon_progress = {marksman: :award, sharpshooter: 75, expert: 0}

      result = render_weapon_badge(weapon_progress, @awards)

      assert_includes result, "square-check"           # Marksman badge
      assert_includes result, " + 75%"                 # Progress toward sharpshooter
      assert_includes result, "Marksman + 75% toward Sharpshooter" # Tooltip content
    end

    test "when user has marksman badge but no sharpshooter progress, it shows badge without progress" do
      weapon_progress = {marksman: :award, sharpshooter: 0, expert: 0}

      result = render_weapon_badge(weapon_progress, @awards)

      assert_includes result, "square-check"
      assert_includes result, 'data-toggle="tooltip"'  # Still has tooltip
      assert_includes result, "Marksman"      # Just the badge title
      refute_includes result, " + "                    # No progress shown
    end

    test "when user has no badges but has marksman progress, it shows progress toward marksman" do
      weapon_progress = {marksman: 45, sharpshooter: 30, expert: 10}

      result = render_weapon_badge(weapon_progress, @awards)

      assert_includes result, "45%"
      assert_includes result, "45% toward Marksman"    # Tooltip shows progress info
      refute_includes result, "square-check"  # No badge shown
      refute_includes result, " + "           # No next level progress shown
    end

    test "when user has no badges and no progress, it displays em dash" do
      weapon_progress = {marksman: 0, sharpshooter: 0, expert: 0}

      result = render_weapon_badge(weapon_progress, @awards)

      assert_includes result, "&mdash;"
      refute_includes result, "square-check"
    end
  end
end
