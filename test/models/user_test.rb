require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "full_name includes middle initial if middle name present" do
    user = create(:user, first_name: "Grace", middle_name: "Brewster",
                         last_name: "Hopper")
    assert_equal "Grace B. Hopper", user.full_name
  end

  test "full_name excludes middle initial if middle name not present" do
    user = create(:user, first_name: "Grace", last_name: "Hopper")
    assert_equal "Grace Hopper", user.full_name
  end

  test "short_name includes name prefix if present" do
    user = create(:user, name_prefix: "B.", last_name: "Hopper")
    assert_equal "Pvt. B. Hopper", user.short_name
  end

  test "short_name excludes name prefix if not present" do
    user = create(:user, last_name: "Hopper")
    assert_equal "Pvt. Hopper", user.short_name

    user = create(:user, name_prefix: "", last_name: "Hopper")
    assert_equal "Pvt. Hopper", user.short_name
  end

  test "refresh_rank uses latest promotion" do
    user = create(:user, rank_abbr: "Pvt.")
    create(:promotion, user: user, date: 3.days.ago, rank_abbr: "Cpl.") # latest
    create(:promotion, user: user, date: 1.week.ago, rank_abbr: "Sgt.")

    user.refresh_rank
    assert_equal "Cpl.", user.rank.abbr
  end

  test "refresh_rank uses default rank if no promotions exist" do
    user = create(:user, rank_abbr: "Cpl.")

    user.refresh_rank
    assert_equal "Pvt.", user.rank.abbr
  end

  # has_permission?

  test "leader inherits member and elevated permissions" do
    unit = create(:unit)
    create(:permission, :leader, abbr: "leader_ability", unit: unit)
    create(:permission, :elevated, abbr: "elevated_ability", unit: unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, :leader, user: user, unit: unit)

    assert user.has_permission? "leader_ability"
    assert user.has_permission? "elevated_ability"
    assert user.has_permission? "member_ability"
  end

  test "elevated inherits member permissions but not leader" do
    unit = create(:unit)
    create(:permission, :leader, abbr: "leader_ability", unit: unit)
    create(:permission, :elevated, abbr: "elevated_ability", unit: unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, :elevated, user: user, unit: unit)

    refute user.has_permission? "leader_ability"
    assert user.has_permission? "elevated_ability"
    assert user.has_permission? "member_ability"
  end

  # forum_role_ids

  test "forum_role_ids leader inherits member and elevated permissions" do
    unit = create(:unit)
    leader_role = create(:unit_forum_role, :leader, unit: unit)
    elevated_role = create(:unit_forum_role, :elevated, unit: unit)
    member_role = create(:unit_forum_role, unit: unit)

    user = create(:user)
    create(:assignment, :leader, user: user, unit: unit)

    roles = user.forum_role_ids(:discourse)

    assert roles.include?(leader_role.role_id), "missing leader role"
    assert roles.include?(elevated_role.role_id), "missing elevated role"
    assert roles.include?(member_role.role_id), "missing member role"
  end

  test "forum_role_ids elevated inherits member permissions but not leader" do
    unit = create(:unit)
    leader_role = create(:unit_forum_role, :leader, unit: unit)
    elevated_role = create(:unit_forum_role, :elevated, unit: unit)
    member_role = create(:unit_forum_role, unit: unit)

    user = create(:user)
    create(:assignment, :elevated, user: user, unit: unit)

    roles = user.forum_role_ids(:discourse)

    refute roles.include?(leader_role.role_id), "includes leader role"
    assert roles.include?(elevated_role.role_id), "missing elevated role"
    assert roles.include?(member_role.role_id), "missing member role"
  end

  test "forum_role_ids returns unique values" do
    unit = create(:unit)
    role = create(:unit_forum_role, unit: unit)

    other_unit = create(:unit)
    other_role = create(:unit_forum_role, unit: other_unit)
    create(:unit_forum_role, unit: other_unit, role_id: role.role_id) # duplicate

    user = create(:user)
    create(:assignment, user: user, unit: unit)
    create(:assignment, user: user, unit: other_unit)

    roles = user.forum_role_ids(:discourse)

    assert_equal roles.size, 2
    assert roles.include?(role.role_id)
    assert roles.include?(other_role.role_id)
  end

  test "forum_role_ids only returns roles for forum specified" do
    unit = create(:unit)
    discourse_role = create(:unit_forum_role, unit: unit, forum_id: :discourse)
    vanilla_role = create(:unit_forum_role, unit: unit, forum_id: :vanilla)
    user = create(:user)
    create(:assignment, user: user, unit: unit)

    roles = user.forum_role_ids(:discourse)

    assert roles.include?(discourse_role.role_id), "missing role for specified forum"
    refute roles.include?(vanilla_role.role_id), "includes role for another forum"
  end

  # has_permission_on_unit?

  test "permission applies to unit" do
    unit = create(:unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    assert user.has_permission_on_unit? "member_ability", unit
  end

  test "permission applies to child unit" do
    unit = create(:unit)
    child_unit = create(:unit, parent: unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    assert user.has_permission_on_unit? "member_ability", child_unit
  end

  test "permission does not apply to child unit of another unit" do
    unit = create(:unit)
    other_unit = create(:unit)
    other_child_unit = create(:unit, parent: other_unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    refute user.has_permission_on_unit? "member_ability", other_child_unit
  end

  test "permission does not apply to parent unit" do
    parent_unit = create(:unit)
    unit = create(:unit, parent: parent_unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    refute user.has_permission_on_unit? "member_ability", parent_unit
  end

  test "permission from past assignments are ignored" do
    unit = create(:unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit,
                        start_date: 2.weeks.ago, end_date: 1.week.ago)

    refute user.has_permission_on_unit? "member_ability", unit
  end

  test "permission from future assignments are ignored" do
    unit = create(:unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit,
                        start_date: 1.week.from_now)

    refute user.has_permission_on_unit? "member_ability", unit
  end

  # has_permission_on_user?

  test "permission applies to user in their unit" do
    unit = create(:unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    create(:assignment, user: subject, unit: unit)

    assert user.has_permission_on_user? "member_ability", subject
  end

  test "permission applies to user in child unit" do
    unit = create(:unit)
    child_unit = create(:unit, parent: unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    create(:assignment, user: subject, unit: child_unit)

    assert user.has_permission_on_user? "member_ability", subject
  end

  test "permission does not apply to self" do
    unit = create(:unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    refute user.has_permission_on_user? "member_ability", user
  end

  test "permission does not apply to user in child unit of another unit" do
    unit = create(:unit)
    other_unit = create(:unit)
    other_child_unit = create(:unit, parent: other_unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    create(:assignment, user: subject, unit: other_child_unit)

    refute user.has_permission_on_user? "member_ability", subject
  end

  test "permission does not apply to user who used to be in unit" do
    unit = create(:unit)
    create(:permission, abbr: "member_ability", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    subject = create(:user)
    create(:assignment, user: subject, unit: unit, end_date: 2.days.ago)

    refute user.has_permission_on_user? "member_ability", subject
  end

  test "permission on user can come from multiple intersecting assignments" do
    lighthouse = create(:unit)
    create(:permission, abbr: "fire", unit: lighthouse)

    squad = create(:unit)
    create(:permission, abbr: "qualify", unit: squad)

    user = create(:user)
    create(:assignment, user: user, unit: lighthouse)
    create(:assignment, user: user, unit: squad)

    subject = create(:user)
    create(:assignment, user: subject, unit: lighthouse)
    create(:assignment, user: subject, unit: squad)

    assert user.has_permission_on_user? "fire", subject
    assert user.has_permission_on_user? "qualify", subject
  end

  test "permission is exclusive to the intersecting assignment" do
    lighthouse = create(:unit)
    create(:permission, abbr: "fire", unit: lighthouse)

    squad = create(:unit)
    create(:permission, abbr: "qualify", unit: squad)
    other_squad = create(:unit)

    user = create(:user)
    create(:assignment, user: user, unit: lighthouse)
    create(:assignment, user: user, unit: squad)

    subject = create(:user)
    create(:assignment, user: subject, unit: lighthouse)
    create(:assignment, user: subject, unit: other_squad)

    assert user.has_permission_on_user? "fire", subject
    refute user.has_permission_on_user? "qualify", subject
  end

  # member?
  test "member? is only true if user has active combat or staff assignment" do
    combat_user = create(:user)
    combat_unit = create(:unit, classification: :combat)
    create(:assignment, user: combat_user, unit: combat_unit)
    assert combat_user.member?

    staff_user = create(:user)
    staff_unit = create(:unit, classification: :staff)
    create(:assignment, user: staff_user, unit: staff_unit)
    assert staff_user.member?

    training_user = create(:user)
    training_unit = create(:unit, classification: :training)
    create(:assignment, user: training_user, unit: training_unit)
    refute training_user.member?

    multi_user = create(:user)
    create(:assignment, user: multi_user, unit: combat_unit)
    create(:assignment, user: multi_user, unit: staff_unit)
    assert multi_user.member?

    guest_user = create(:user)
    refute guest_user.member?
  end

  test "member? ignores past assignments" do
    user = create(:user)
    unit = create(:unit, classification: :combat)
    create(:assignment, user: user, unit: unit,
                        end_date: 2.days.ago)
    refute user.member?
  end

  # honorably_discharged?
  test "honorably_discharged? passes for honorably discharged member" do
    user = create(:user)
    unit = create(:unit, classification: :combat)
    create(:assignment, user: user, unit: unit, end_date: 2.days.ago)
    create(:discharge, user: user, type: :honorable)

    assert user.honorably_discharged?
  end

  test "honorably_discharged? fails for member honorably discharged in the past, but more recently generally discharged" do
    user = create(:user)
    unit = create(:unit, classification: :combat)
    create(:assignment, user: user, unit: unit, end_date: 2.years.ago)
    create(:discharge, user: user, type: :honorable, date: 1.year.ago)
    create(:assignment, user: user, unit: unit, end_date: 2.days.ago)
    create(:discharge, user: user, type: :general, date: 1.day.ago)

    refute user.honorably_discharged?
  end

  test "honorably_discharged? fails for member honorably discharged in the past, but currently active" do
    user = create(:user)
    unit = create(:unit, classification: :combat)
    create(:assignment, user: user, unit: unit, end_date: 2.years.ago)
    create(:discharge, user: user, type: :honorable)
    create(:assignment, user: user, unit: unit, start_date: 2.days.ago)

    refute user.honorably_discharged?
  end
end
