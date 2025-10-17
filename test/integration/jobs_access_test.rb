require "test_helper"

class JobsAccessTest < ActionDispatch::IntegrationTest
  def setup
    MissionControl::Jobs::Engine.stubs(:call)
      .returns([200, {"Content-Type" => "text/plain"}, ["OK"]])
  end

  def teardown
    MissionControl::Jobs::Engine.unstub(:call)
  end

  test "allows access for users with admin permission" do
    unit = create(:unit)
    create(:permission, :leader, abbr: "admin", unit: unit)
    user = create(:user)
    create(:assignment, :leader, unit: unit, user: user)

    sign_in_as user

    get "/jobs"

    assert_response :success
  end

  test "returns not found for signed-in users without admin permission" do
    unit = create(:unit)
    user = create(:user)
    create(:assignment, :leader, unit: unit, user: user)

    sign_in_as user

    get "/jobs"

    assert_response :not_found
  end

  test "returns not found for unauthenticated visitors" do
    get "/jobs"

    assert_response :not_found
  end
end
