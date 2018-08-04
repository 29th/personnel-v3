require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # has_permission?

  test "Platoon leader inherits member and clerk permissions" do
    lt_chicken = users(:lt_chicken)

    assert lt_chicken.has_permission? 'add_promotion' # leader-level
    assert lt_chicken.has_permission? 'add_event' # clerk-level
    assert lt_chicken.has_permission? 'view_event' # member-level
  end

  test "Platoon clerk inherits member permissions but not leader abilities" do
    t5_dingo = users(:t5_dingo)

    refute t5_dingo.has_permission? 'add_promotion' # leader-level
    assert t5_dingo.has_permission? 'add_event' # clerk-level
    assert t5_dingo.has_permission? 'view_event' # member-level
  end

  # has_permission_on_unit?

  test "Platoon leader's platoon-level permission applies to the platoon" do
    lt_chicken = users(:lt_chicken)
    ap1 = units(:ap1)

    assert lt_chicken.has_permission_on_unit? 'view_event', ap1 # member-level
  end

  test "Platoon leader's platoon-level permissions apply to one of their squads" do
    lt_chicken = users(:lt_chicken)
    ap1s1 = units(:ap1s1)

    assert lt_chicken.has_permission_on_unit? 'add_event', ap1s1 # clerk-level
  end

  test "Platoon leader's permissions do not apply to another platoon's squad" do
    lt_chicken = users(:lt_chicken)
    ap2s1 = units(:ap2s1)

    assert_not lt_chicken.has_permission_on_unit? 'add_event', ap2s1 # clerk-level
  end

  test "Squad leader's permissions do not apply to their platoon" do
    sgt_baboon = users(:sgt_baboon)
    ap1 = units(:ap1)

    assert_not sgt_baboon.has_permission_on_unit? 'view_event', ap1 # member-level
  end
end
