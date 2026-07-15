require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "public informational pages render" do
    create(:server) # /servers groups active servers by game

    %w[
      /about /about/awards /about/realism /about/ranks /about/historical
      /about/server /about/faq /about/record /about/ourhistory
      /contact /donate /servers /enlist
    ].each do |path|
      get path
      assert_response :success, "expected #{path} to render"
    end
  end
end
