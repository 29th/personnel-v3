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
end
