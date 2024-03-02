require "test_helper"

class EnlistmentPolicyTest < ActiveSupport::TestCase
  test "anonymous user CANNOT create" do
    refute_permit nil, Enlistment, :create
  end

  test "unregistered user CAN create" do
    user = build(:user, :unregistered)
    assert_permit user, Enlistment, :create
  end

  test "existing user CAN create" do
    user = build(:user)
    assert_permit user, Enlistment, :create
  end

  test "member CANNOT create" do
    user = create(:user)
    unit = create(:unit, classification: :combat)
    create(:assignment, user: user, unit: unit)
    refute_permit user, Enlistment, :create
  end

  test "user assigned to training unit CANNOT create" do
    user = create(:user)
    tp = create(:unit, classification: :training)
    create(:assignment, user: user, unit: tp)
    refute_permit user, Enlistment, :create
  end

  test "user with pending enlistment CANNOT create" do
    user = create(:user)
    create(:enlistment, user: user, status: :pending)
    refute_permit user, Enlistment, :create
  end
end
