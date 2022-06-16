require "test_helper"

class VanillaServiceTest < ActiveSupport::TestCase
  test "update_display_name uses user.short_name" do
    vanilla_forum_member_id = 1
    user = create(:user, last_name: "Panda", vanilla_forum_member_id: vanilla_forum_member_id)

    request_body = {name: user.short_name}
    stub_update = stub_request(:patch, %r{/users/#{vanilla_forum_member_id}})
      .with(body: request_body.to_json)

    VanillaService.new.update_user_display_name(vanilla_forum_member_id, user.short_name)

    assert_requested(stub_update)
  end

  test "update_user_roles sends expected roles" do
    vanilla_forum_member_id = 1
    user = create(:user, vanilla_forum_member_id: vanilla_forum_member_id, forum_member_id: nil)
    unit = create(:unit)
    create(:assignment, user: user, unit: unit)

    roles = create_list(:unit_forum_role, 2, unit: unit, forum_id: :vanilla)

    expected_body = {roleID: roles.map(&:role_id).sort}
    stub = stub_request(:patch, %r{/users/#{vanilla_forum_member_id}})
      .with(body: expected_body.to_json)

    user.update_forum_roles

    assert_requested(stub)
  end
end
