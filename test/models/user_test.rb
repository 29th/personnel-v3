require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # has_permission?

  test "Platoon leader inherits member and elevated permissions" do
    lt_chicken = users(:lt_chicken)

    assert lt_chicken.has_permission? 'add_promotion' # leader-level
    assert lt_chicken.has_permission? 'add_event' # elevated-level
    assert lt_chicken.has_permission? 'view_event' # member-level
  end

  test "Platoon elevated inherits member permissions but not leader abilities" do
    t5_dingo = users(:t5_dingo)

    refute t5_dingo.has_permission? 'add_promotion' # leader-level
    assert t5_dingo.has_permission? 'add_event' # elevated-level
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

    assert lt_chicken.has_permission_on_unit? 'add_event', ap1s1 # elevated-level
  end

  test "Platoon leader's permissions do not apply to another platoon's squad" do
    lt_chicken = users(:lt_chicken)
    ap2s1 = units(:ap2s1)

    assert_not lt_chicken.has_permission_on_unit? 'add_event', ap2s1 # elevated-level
  end

  test "Squad leader's permissions do not apply to their platoon" do
    sgt_baboon = users(:sgt_baboon)
    ap1 = units(:ap1)

    assert_not sgt_baboon.has_permission_on_unit? 'view_event', ap1 # member-level
  end

  test "Permissions from past assignments are ignored" do
    lt_chicken = users(:lt_chicken)
    ap2 = units(:ap2)

    assert_not lt_chicken.has_permission_on_unit? 'add_event', ap2 # elevated-level
  end

  test "Permissions from future assignments are ignored" do
    pvt_antelope = users(:pvt_antelope)
    ap1 = units(:ap1)

    assert_not pvt_antelope.has_permission_on_unit? 'add_event', ap1 # elevated-level
  end

  # has_permission_on_user?

  test "Platoon leader has permissions on a member of one of their squads" do
    lt_chicken = users(:lt_chicken)
    pvt_antelope = users(:pvt_antelope)

    assert lt_chicken.has_permission_on_user? 'edit_profile', pvt_antelope # elevated-level
  end

  test "Platoon leader does not have permissions on a member of another platoon's squads" do
    lt_chicken = users(:lt_chicken)
    pvt_emu = users(:pvt_emu)

    assert_not lt_chicken.has_permission_on_user? 'edit_profile', pvt_emu # elevated-level
  end

  test "Lighthouse chief has permission to fire and qualify someone who's in their squad and also in lighthouse" do
    sgt_baboon = users(:sgt_baboon)
    pvt_antelope = users(:pvt_antelope)

    assert sgt_baboon.has_permission_on_user? 'fire', pvt_antelope # lighthouse leader-level
    assert sgt_baboon.has_permission_on_user? 'qualify', pvt_antelope # ap1s1 leader-level
  end

  test "Lighthouse chief has permission to fire but not qualify someone who's in lighthouse, but not their squad" do
    sgt_baboon = users(:sgt_baboon)
    pvt_emu = users(:pvt_emu)

    assert sgt_baboon.has_permission_on_user? 'fire', pvt_emu # lighthouse leader-level
    assert_not sgt_baboon.has_permission_on_user? 'qualify', pvt_emu # ap1s1 leader-level
  end
end
