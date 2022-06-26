module EventsHelper
  def safe_bbcode(input)
    sanitizer = Rails::Html::SafeListSanitizer.new
    html = input.bbcode_to_html({}, false)
    simple_format(sanitizer.sanitize(html))
  end
end
