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

  # Determines what to display for a weapon: highest badge earned + progress toward next level
  # weapon_progress: hash with keys [:marksman, :sharpshooter, :expert] containing progress or :award
  # awards: hash with keys [:marksman, :sharpshooter, :expert] containing Award objects
  def render_weapon_badge(weapon_progress, awards)
    marksman = weapon_progress[:marksman]
    sharpshooter = weapon_progress[:sharpshooter]
    expert = weapon_progress[:expert]

    if expert == :award
      display_content = render_progress_award(awards[:expert])
      tooltip_text = "Expert"
    elsif sharpshooter == :award
      if expert.is_a?(Integer) && expert > 0
        display_content = "#{render_progress_award(awards[:sharpshooter])} + #{expert}%".html_safe
        tooltip_text = "Sharpshooter + #{expert}% toward Expert"
      else
        display_content = render_progress_award(awards[:sharpshooter])
        tooltip_text = "Sharpshooter"
      end
    elsif marksman == :award
      if sharpshooter.is_a?(Integer) && sharpshooter > 0
        display_content = "#{render_progress_award(awards[:marksman])} + #{sharpshooter}%".html_safe
        tooltip_text = "Marksman + #{sharpshooter}% toward Sharpshooter"
      else
        display_content = render_progress_award(awards[:marksman])
        tooltip_text = "Marksman"
      end
    else
      display_content = render_progress(marksman, awards[:marksman])
      tooltip_text = "#{marksman}% toward Marksman"
    end

    content_tag(:span, display_content, title: tooltip_text, "data-toggle": "tooltip", "data-controller": "tooltip")
  end
end
