require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  setup do
    @base_url = Rails.configuration.endpoints[:personnel_v2_app][:base_url][:external]
  end

  test "v2 url helper returns base_url when given no args" do
    subject = personnel_v2_app_url
    assert_equal @base_url, subject
  end

  test "v2 url helper returns member fragment when passed user instance" do
    user = create(:user)
    subject = personnel_v2_app_url(user: user)
    assert_equal "#{@base_url}/#members/#{user.id}", subject
  end

  test "v2 url helper returns member fragment when passed user id" do
    user = create(:user)
    subject = personnel_v2_app_url(user: user.id)
    assert_equal "#{@base_url}/#members/#{user.id}", subject
  end

  test "v2 url helper returns member fragment with suffix when passed suffix" do
    user = create(:user)
    subject = personnel_v2_app_url(user: user, suffix: "attendance")
    assert_equal "#{@base_url}/#members/#{user.id}/attendance", subject
  end

  test "v2 url helper returns unit fragment when passed unit instance" do
    unit = create(:unit)
    subject = personnel_v2_app_url(unit: unit)
    assert_equal "#{@base_url}/#units/#{unit.id}", subject
  end
end
