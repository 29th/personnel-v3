require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "Platoon leader inherits member and clerk abilities" do
    lt_chicken_permissions = users(:lt_chicken).permissions

    assert_includes lt_chicken_permissions, 'add_promotion' # leader-level
    assert_includes lt_chicken_permissions, 'add_event' # clerk-level
    assert_includes lt_chicken_permissions, 'view_event' # member-level
  end

  test "Platoon clerk inherits member abilities but not leader abilities" do
    t5_dingo_permissions = users(:t5_dingo).permissions

    refute_includes t5_dingo_permissions, 'add_promotion' # leader-level
    assert_includes t5_dingo_permissions, 'add_event' # clerk-level
    assert_includes t5_dingo_permissions, 'view_event' # member-level
  end
end
