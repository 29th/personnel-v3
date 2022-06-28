module EventsHelper
  def safe_bbcode(input)
    sanitizer = Rails::Html::SafeListSanitizer.new
    html = input.bbcode_to_html({}, false)
    simple_format(sanitizer.sanitize(html))
  end

  def calendar_wrapper(options = {}, &block)
    if options[:view_by] == "month"
      month_calendar(options, &block)
    else
      week_calendar(options, &block)
    end
  end
end
