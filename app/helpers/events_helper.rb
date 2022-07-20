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

  # Event timestamps are stored in ET in the database.
  # Rails assumes they're in UTC, and we've told rails
  # *not* to convert them to ET (because they already
  # are in ET). So we have to convert it to a string
  # and *then* tack on the time zone, and then format
  # the time zone as an abbreviation instead of offset.
  # see: https://github.com/29th/personnel/issues/593
  def format_timestamp(datetime)
    datetime.strftime("%F %R") # removes time zone
      .in_time_zone(Time.zone) # adds correct time zone
      .strftime("%F %R %Z") # formats time zone as abbr
  end
end
