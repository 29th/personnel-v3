require "test_helper"

class PassPolicyTest < ActiveSupport::TestCase
  test "create permits user with pass_edit_any" do
    unit = create(:unit)
    create(:permission, abbr: "pass_edit_any", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    pass = build(:pass, user: subject)

    assert_permit user, pass, :create
  end

  test "create permits user with pass_edit on subject in scope" do
    unit = create(:unit)
    create(:permission, abbr: "pass_edit", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    create(:assignment, user: subject, unit: unit)
    pass = build(:pass, user: subject)

    assert_permit user, pass, :create
  end

  test "create denies user with pass_edit on subject out of scope" do
    unit = create(:unit)
    create(:permission, abbr: "pass_edit", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    other_unit = create(:unit)
    create(:assignment, user: subject, unit: other_unit)
    pass = build(:pass, user: subject)

    refute_permit user, pass, :create
  end
end
