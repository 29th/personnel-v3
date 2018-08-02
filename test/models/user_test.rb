require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "Platoon leader inherits member and clerk abilities" do
    lt_chicken = users(:lt_chicken)

    assert lt_chicken.has_permission? 'add_promotion' # leader-level
    assert lt_chicken.has_permission? 'add_event' # clerk-level
    assert lt_chicken.has_permission? 'view_event' # member-level
  end

  test "Platoon clerk inherits member abilities but not leader abilities" do
    t5_dingo = users(:t5_dingo)

    refute t5_dingo.has_permission? 'add_promotion' # leader-level
    assert t5_dingo.has_permission? 'add_event' # clerk-level
    assert t5_dingo.has_permission? 'view_event' # member-level
  end

  test "Platoon leader platoon-level abilities apply to their squad" do
    lt_chicken = users(:lt_chicken)
    ap1s1 = units(:ap1s1)

    assert lt_chicken.has_permission_on_unit? 'add_event', ap1s1 # clerk-level
  end
end
