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

  def unit_total_size(unit, unit_tree, assignments)
    # Collect unique user IDs from this unit and all subunits
    unique_user_ids = collect_unique_user_ids(unit, unit_tree, assignments, Set.new)
    unique_user_ids.size
  end

  def render_progress(achievement, progress)
    if achievement == :eib || achievement == :slt
      render_basic_progress(achievement, progress[:notapplicable])
    elsif progress.key?(:marksman)
      render_weapon_progress(progress)
    end
  end

  private

  def collect_unique_user_ids(unit, unit_tree, assignments, user_ids_set)
    # Add user IDs from direct assignments to this unit
    if assignments.key?(unit.id)
      assignments[unit.id].each do |assignment|
        user_ids_set.add(assignment.user.id)
      end
    end

    # Find children of this unit in the tree
    children = unit_tree[unit] || {}

    # Recursively collect user IDs from all subunits
    children.each do |child_unit, child_tree|
      collect_unique_user_ids(child_unit, {child_unit => child_tree}, assignments, user_ids_set)
    end

    user_ids_set
  end

  def render_basic_progress(achievement, percentage)
    if percentage == :award
      render_award(achievement)
    elsif percentage.is_a?(Integer) && percentage > 0
      content_tag(:span, "#{percentage}%")
    else
      content_tag(:span, "&mdash;".html_safe)
    end
  end

  # Determines what to display for a weapon: highest badge earned + progress toward next level
  # @param progress - hash with keys :marksman, :sharpshooter, :expert containing progress or :award
  def render_weapon_progress(progress)
    marksman = progress[:marksman]
    sharpshooter = progress[:sharpshooter]
    expert = progress[:expert]

    if expert == :award
      display_content = render_award(:expert)
      tooltip_text = "Expert"
    elsif sharpshooter == :award
      if expert > 0
        display_content = "#{render_award(:sharpshooter)} + #{expert}%".html_safe
        tooltip_text = "Sharpshooter + #{expert}% toward Expert"
      else
        display_content = render_award(:sharpshooter)
        tooltip_text = "Sharpshooter"
      end
    elsif marksman == :award
      if sharpshooter > 0
        display_content = "#{render_award(:marksman)} + #{sharpshooter}%".html_safe
        tooltip_text = "Marksman + #{sharpshooter}% toward Sharpshooter"
      else
        display_content = render_award(:marksman)
        tooltip_text = "Marksman"
      end
    else
      display_content = "#{marksman}%"
      tooltip_text = "#{marksman}% toward Marksman"
    end

    content_tag(:span, display_content, title: tooltip_text, "data-toggle": "tooltip", "data-controller": "tooltip")
  end

  def render_award(achievement)
    case achievement
    when :eib
      image_tag("awards/eib.gif", alt: "Expert Infantry Badge", class: "inline-award", title: "Expert Infantry Badge")
    when :slt
      image_tag("awards/anpdr.gif", alt: "Army NCO Professional Development Ribbon", class: "inline-award", title: "Army NCO Professional Development Ribbon")
    when :marksman
      image_tag("awards/marksman.gif", alt: "Marksman", class: "inline-badge", title: "Marksman")
    when :sharpshooter
      image_tag("awards/sharpshooter.gif", alt: "Sharpshooter", class: "inline-badge", title: "Sharpshooter")
    when :expert
      image_tag("awards/expert.gif", alt: "Expert", class: "inline-badge", title: "Expert")
    else
      icon("fa-solid", "square-check")
    end
  end
end
