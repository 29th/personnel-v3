require "test_helper"

class VanillaServiceTest < ActiveSupport::TestCase
  test "update_display_name uses user.short_name" do
    vanilla_forum_member_id = 1
    user = create(:user, last_name: "Panda", vanilla_forum_member_id: vanilla_forum_member_id)

    request_body = {name: user.short_name}
    stub_update = stub_request(:patch, %r{/users/#{vanilla_forum_member_id}})
      .with(body: request_body.to_json)

    VanillaService.new(vanilla_forum_member_id).user.update_display_name(user.short_name)

    assert_requested(stub_update)
  end

  test "update_roles sends expected roles" do
    vanilla_forum_member_id = 1
    user = create(:user, vanilla_forum_member_id: vanilla_forum_member_id)
    user.update(forum_member_id: nil) # don't execute discourse request
    unit = create(:unit)
    create(:assignment, user: user, unit: unit)

    roles = create_list(:unit_forum_role, 2, unit: unit, forum_id: :vanilla)

    expected_body = {roleID: roles.map(&:role_id).sort}
    stub = stub_request(:patch, %r{/users/#{vanilla_forum_member_id}})
      .with(body: expected_body.to_json)

    user.update_forum_roles

    assert_requested(stub)
  end

  test "linked_users groups ips by user" do
    vanilla_user_id = 1

    response_body = {ips: [
      {ip: "1.2.3.4", otherUsers: []},
      {ip: "5.6.7.8", otherUsers: [
        {userID: 3, name: "abe_lincoln"},
        {userID: 4, name: "eleanor_roosevelt"}
      ]},
      {ip: "9.10.11.12", otherUsers: [
        {userID: 3, name: "abe_lincoln"}
      ]}
    ]}
    stub_request(:get, %r{/users/#{vanilla_user_id}})
      .to_return(body: response_body.to_json, headers: {"Content-Type" => "application/json"})

    linked_users = VanillaService.new(vanilla_user_id).user.linked_users

    assert_equal 2, linked_users.size

    abe = linked_users.find { |user| user[:username] == "abe_lincoln" }
    assert abe
    assert_equal 3, abe[:user_id]
    assert_equal ["5.6.7.8", "9.10.11.12"], abe[:ips]

    eleanor = linked_users.find { |user| user[:username] == "eleanor_roosevelt" }
    assert eleanor
    assert_equal 1, eleanor[:ips].size
  end
end
