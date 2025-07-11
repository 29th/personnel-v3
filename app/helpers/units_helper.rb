module UnitsHelper
  # Returns the appropriate CSS class based on attendance percentage
  #
  # @param percentage [Float] The attendance percentage
  # @return [String] The CSS class for styling
  def attendance_badge_class(percentage)
    case percentage.round
    when 0..25
      "text-danger"    # Red for poor attendance
    when 26..50
      "text-warning"   # Yellow/Orange for mediocre attendance
    when 51..75
      "text-info"      # Light blue for good attendance
    when 76..100
      "text-success"   # Green for excellent attendance
    else
      ""
    end
  end

  def render_progress(progress, award)
    if progress == :award
      render_progress_award(award)
    elsif progress.is_a?(Integer) && progress > 0
      content_tag(:span, "#{progress}%")
    else
      content_tag(:span, "&mdash;".html_safe)
    end
  end

  def render_progress_award(award)
    if award&.ribbon_image.present?
      image_tag(award.ribbon_image.url, alt: award.title, class: "inline-award", title: award.title)
    else
      icon("fa-solid", "square-check")
    end
  end
end
