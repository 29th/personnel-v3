require 'test_helper'

class UserAwardPolicyTest < ActiveSupport::TestCase
  test "create permits user with awarding_add_any" do
    unit = create(:unit)
    create(:permission, abbr: 'awarding_add_any', unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    user_award = build(:user_award, user: subject)

    assert_permit user, user_award, :create
  end

  test "create permits user with awarding_add on subject on scope" do
    unit = create(:unit)
    create(:permission, abbr: 'awarding_add', unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    create(:assignment, user: subject, unit: unit)
    user_award = build(:user_award, user: subject)

    assert_permit user, user_award, :create
  end

  test "create denies user with awarding_add on subject out of scope" do
    unit = create(:unit)
    create(:permission, abbr: 'awarding_add', unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    other_unit = create(:unit)
    create(:assignment, user: subject, unit: other_unit)
    user_award = build(:user_award, user: subject)

    refute_permit user, user_award, :create
  end
end
