require "test_helper"

class MaintenanceTasksAccessTest < ActionDispatch::IntegrationTest
  test "allows access for users with admin permission" do
    unit = create(:unit)
    create(:permission, :leader, abbr: "admin", unit: unit)
    user = create(:user)
    create(:assignment, :leader, unit: unit, user: user)

    sign_in_as user

    get "/maintenance_tasks"

    assert_response :success
  end

  test "returns not found for signed-in users without admin permission" do
    unit = create(:unit)
    user = create(:user)
    create(:assignment, :leader, unit: unit, user: user)

    sign_in_as user

    get "/maintenance_tasks"

    assert_response :not_found
  end

  test "returns not found for unauthenticated visitors" do
    get "/maintenance_tasks"

    assert_response :not_found
  end
end
