require "test_helper"

class VanillaServiceTest < ActiveSupport::TestCase
  test "update_display_name uses user.short_name" do
    vanilla_user_id = 1
    user = create(:user, last_name: "Panda", forum_member_id: vanilla_user_id)

    request_body = {name: user.short_name}
    stub_update = stub_request(:patch, %r{/users/#{vanilla_user_id}})
      .with(body: request_body.to_json)

    VanillaService.new.update_user_display_name(user)

    assert_requested(stub_update)
  end

  test "update_display_name throws NoLinkedAccountError when forum_member_id is empty" do
    user = create(:user, forum_member_id: nil)

    assert_raises VanillaService::NoLinkedAccountError do
      VanillaService.new.update_user_display_name(user)
    end
  end

  test "update_user_roles sends expected roles" do
    vanilla_user_id = 1
    user = create(:user, forum_member_id: vanilla_user_id)
    unit = create(:unit)
    create(:assignment, user: user, unit: unit)

    roles = create_list(:unit_forum_role, 2, unit: unit, forum_id: :vanilla)

    expected_body = {roleID: roles.map(&:role_id).sort}
    stub = stub_request(:patch, %r{/users/#{vanilla_user_id}})
      .with(body: expected_body.to_json)

    VanillaService.new.update_user_roles(user)

    assert_requested(stub)
  end
end
