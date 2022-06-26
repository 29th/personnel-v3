require "test_helper"

class EventsHelperTest < ActionView::TestCase
  test "safe_bbcode renders bb code as html" do
    text = %([b]Hello, world![/b])
    output = safe_bbcode(text)
    assert_dom_equal %(<p><strong>Hello, world!</strong></p>), output
  end

  test "safe_bbcode removes malicious tags" do
    text = %{<h1>Hello, <script>alert('malicious')</script>!</h1>}
    output = safe_bbcode(text)
    doc = Nokogiri::HTML::Document.parse(output)
    assert_select doc.root, "script", false
  end

  # test "safe_bbcode allows <center> tag" do
  #   text = %(<center>Text</center>)
  #   output = safe_bbcode(text)
  #   assert_dom_equal %(<p><center>Text</center></p>), output
  # end
end
