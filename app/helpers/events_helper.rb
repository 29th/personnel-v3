module EventsHelper
  DATETIME_FORMAT = "%F %R %Z".freeze

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

  def timestamp_tag(starts_at, format = DATETIME_FORMAT)
    comparison = compare_timezones(starts_at)
    content = starts_at.strftime(format)
    tag.time(content, :datetime => starts_at.utc.iso8601, :title => comparison,
      "data-toggle" => "tooltip", "data-controller" => "tooltip")
  end

  def format_timestamp(starts_at)
    starts_at.strftime(DATETIME_FORMAT)
  end

  def compare_timezones(starts_at)
    current_user_time_zone = starts_at.time_zone

    Event::TIMEZONES
      .map { |tz| ActiveSupport::TimeZone[tz] }
      .append(current_user_time_zone)
      .uniq
      .map { |tz| starts_at.in_time_zone(tz) }
      .sort
      .map do |time|
        str = time.strftime(DATETIME_FORMAT)
        time.time_zone == current_user_time_zone ? bolden(str) : str
      end
      .join(tag(:br))
  end

  def timezone_dropdown_options
    Event::TIMEZONES
  end

  def build_time(time_zone:, date_time: nil, date: nil, time: nil)
    tz = Time.find_zone(time_zone)

    if date_time.present?
      tz.parse(date_time)
    elsif date.present? && time.present?
      begin
        parsed_date = Date.parse(date)
        tz.parse(time, parsed_date)
      rescue Date::Error
        nil
      end
    end
  end

  private

  def bolden(str)
    content_tag(:b, str)
  end
end
