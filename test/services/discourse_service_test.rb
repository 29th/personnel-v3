require "test_helper"

class DiscourseServiceTest < ActiveSupport::TestCase
  def stub_user_request(user_id, **kwargs)
    stub_request(:get, %r{/admin/users/#{user_id}.json})
      .to_return(body: kwargs.to_json)
  end

  test "update_display_name uses user.short_name" do
    discourse_user_id = 1
    username = "fluffy_panda"

    user = create(:user, last_name: "Panda", discourse_forum_member_id: discourse_user_id)
    stub_user_request(discourse_user_id, username: username)

    request_body = {name: user.short_name}
    stub_update = stub_request(:put, %r{/u/#{username}})
      .with(body: request_body.to_json)

    DiscourseService.new.update_user_display_name(user)

    assert_requested(stub_update)
  end

  test "update_display_name throws NoLinkedAccountError when discourse_forum_member_id is empty" do
    user = create(:user)

    assert_raises DiscourseService::NoLinkedAccountError do
      DiscourseService.new.update_user_display_name(user)
    end
  end

  test "update_display_name throws if status is 500" do
    discourse_user_id = 1
    username = "fluffy_panda"
    user = create(:user, last_name: "Panda", discourse_forum_member_id: discourse_user_id)
    stub_user_request(discourse_user_id, username: username)

    stub_request(:put, %r{/u/#{username}}).to_return(status: [500, "Internal Server Error"])

    assert_raises HTTParty::ResponseError do
      DiscourseService.new.update_user_display_name(user)
    end
  end

  test "update_user_roles adds missing roles and deletes extra roles" do
    discourse_user_id = 1
    username = "fluffy_panda"

    user = create(:user, discourse_forum_member_id: discourse_user_id)
    unit = create(:unit)
    create(:assignment, user: user, unit: unit)

    synced_roles = create_list(:unit_forum_role, 2, unit: unit)
    missing_role = create(:unit_forum_role, unit: unit)
    extra_role = create(:unit_forum_role)

    discourse_roles = synced_roles.push(extra_role).map { |role| {id: role.role_id} }
    stub_user_request(discourse_user_id, username: username, groups: discourse_roles)

    stub_request(:any, %r{/admin/users/#{discourse_user_id}/groups*})
    DiscourseService.new.update_user_roles(user)

    assert_requested(:post, %r{/admin/users/#{discourse_user_id}/groups}) do |req|
      req.body = {group_id: missing_role.role_id}
    end

    assert_requested(:delete, %r{/admin/users/#{discourse_user_id}/groups/#{extra_role.role_id}})
  end

  test "update_user_roles retries on 429 response" do
    discourse_user_id = 1
    username = "fluffy_panda"

    user = create(:user, discourse_forum_member_id: discourse_user_id)
    unit = create(:unit)
    create(:assignment, user: user, unit: unit)
    missing_role = create(:unit_forum_role, unit: unit)

    stub_user_request(discourse_user_id, username: username, groups: [])
    stub_request(:post, %r{/admin/users/#{discourse_user_id}/groups})
      .to_return({status: 429}, {status: 200})

    DiscourseService.new.update_user_roles(user)

    assert_requested(:post, %r{/admin/users/#{discourse_user_id}/groups}, times: 2) do |req|
      req.body = {group_id: missing_role.role_id}
    end
  end

  test "update_user_roles throws on 500 response" do
    discourse_user_id = 1
    username = "fluffy_panda"

    user = create(:user, discourse_forum_member_id: discourse_user_id)
    unit = create(:unit)
    create(:assignment, user: user, unit: unit)
    create(:unit_forum_role, unit: unit)

    stub_user_request(discourse_user_id, username: username, groups: [])
    stub_request(:post, %r{/admin/users/#{discourse_user_id}/groups})
      .to_return(status: 500)

    assert_raises HTTParty::ResponseError do
      DiscourseService.new.update_user_roles(user)
    end
  end
end
