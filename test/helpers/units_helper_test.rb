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
end
