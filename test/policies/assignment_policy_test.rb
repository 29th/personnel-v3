require "test_helper"

class AssignmentPolicyTest < ActiveSupport::TestCase
  test "show permits non-member" do
    user = create(:user)
    assignment = create(:assignment)
    assert_permit user, assignment, :show
  end

  test "create and update permit user with assignment_add on unit in scope" do
    unit = create(:unit)
    create(:permission, abbr: "assignment_add", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    assignment = create(:assignment, unit: unit)

    assert_permit user, assignment, :create
    assert_permit user, assignment, :update
  end

  test "create and update deny user with assignment_add on unit out of scope" do
    unit = create(:unit)
    create(:permission, abbr: "assignment_add", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    other_unit = create(:unit)
    assignment = create(:assignment, unit: other_unit)

    refute_permit user, assignment, :create
    refute_permit user, assignment, :update
  end

  test "create and update deny if user is self" do
    unit = create(:unit)
    create(:permission, abbr: "assignment_add", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    assignment = create(:assignment, user: user, unit: unit)

    refute_permit user, assignment, :create
    refute_permit user, assignment, :update
  end
end
