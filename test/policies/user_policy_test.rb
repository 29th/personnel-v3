require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  test "update permits user with profile_edit on subject in scope" do
    unit = create(:unit)
    create(:permission, abbr: "profile_edit", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    create(:assignment, user: subject, unit: unit)

    assert_permit user, subject, :update
  end

  test "update denies user with profile_edit on subject out of scope" do
    unit = create(:unit)
    create(:permission, abbr: "profile_edit", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    create(:assignment, user: subject, unit: create(:unit))

    refute_permit user, subject, :update
  end

  test "update denies user with profile_edit acting on self" do
    unit = create(:unit)
    create(:permission, abbr: "profile_edit", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    refute_permit user, user, :update
  end

  test "update permits user with profile_edit_any on subject out of scope" do
    unit = create(:unit)
    create(:permission, abbr: "profile_edit_any", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)

    assert_permit user, subject, :update
  end

  test "member-only pages deny non-members and permit members" do
    member = create(:user)
    create(:assignment, user: member, unit: create(:unit, classification: :combat))
    non_member = create(:user)
    subject = create(:user)

    %i[attendance qualifications reprimands extended_loas].each do |action|
      assert_permit member, subject, action
      refute_permit non_member, subject, action
    end
  end

  test "update_forum_roles permits user with assignment_edit on subject in scope" do
    unit = create(:unit)
    create(:permission, abbr: "assignment_edit", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    create(:assignment, user: subject, unit: unit)

    assert_permit user, subject, :update_forum_roles
  end

  test "update_forum_roles denies user with assignment_edit on subject out of scope" do
    unit = create(:unit)
    create(:permission, abbr: "assignment_edit", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    create(:assignment, user: subject, unit: create(:unit))

    refute_permit user, subject, :update_forum_roles
  end

  test "update_forum_roles on the User class permits any user with assignment_edit" do
    unit = create(:unit)
    create(:permission, abbr: "assignment_edit", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    assert_permit user, User, :update_forum_roles
    refute_permit create(:user), User, :update_forum_roles
  end

  test "update_forum_roles permits user with assignment_edit_any on any subject" do
    unit = create(:unit)
    create(:permission, abbr: "assignment_edit_any", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)

    assert_permit user, subject, :update_forum_roles
  end
end
