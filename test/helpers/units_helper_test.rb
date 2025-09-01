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
end
