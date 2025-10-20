require "test_helper"

class DiscourseServiceTest < ActiveSupport::TestCase
  def stub_user_request(user_id, **kwargs)
    stub_request(:get, %r{/admin/users/#{user_id}.json})
      .to_return(body: kwargs.to_json, headers: {"Content-type": "application/json"})
  end

  test "update_display_name uses user.short_name" do
    forum_member_id = 1
    username = "fluffy_panda"

    user = create(:user, last_name: "Panda", forum_member_id: forum_member_id)
    stub_user_request(forum_member_id, username: username)

    request_body = {name: user.short_name}
    stub_update = stub_request(:put, %r{/u/#{username}})
      .with(body: request_body.to_json)

    DiscourseService.new(forum_member_id).user.update_display_name(user.short_name)

    assert_requested(stub_update)
  end

  test "update_display_name throws if status is 500" do
    forum_member_id = 1
    username = "fluffy_panda"
    user = create(:user, last_name: "Panda", forum_member_id: forum_member_id)
    stub_user_request(forum_member_id, username: username)

    stub_request(:put, %r{/u/#{username}}).to_return(status: [500, "Internal Server Error"])

    assert_raises Faraday::ServerError do
      DiscourseService.new(forum_member_id).user.update_display_name(user.short_name)
    end
  end

  test "update_roles adds missing roles and deletes extra roles" do
    forum_member_id = 1
    username = "fluffy_panda"

    user = create(:user, forum_member_id: forum_member_id)
    unit = create(:unit)
    create(:assignment, user: user, unit: unit)

    synced_roles = create_list(:unit_forum_role, 2, unit: unit)
    missing_role = create(:unit_forum_role, unit: unit)
    extra_role = create(:unit_forum_role)

    discourse_roles = synced_roles.push(extra_role).map { |role| {id: role.role_id} }
    stub_user_request(forum_member_id, username: username, groups: discourse_roles)

    stub_request(:any, %r{/admin/users/#{forum_member_id}/groups*})
    expected_roles = user.forum_role_ids(:discourse)
    DiscourseService.new(forum_member_id).user.update_roles(expected_roles)

    assert_requested(:post, %r{/admin/users/#{forum_member_id}/groups}) do |req|
      req.body = {group_id: missing_role.role_id}
    end

    assert_requested(:delete, %r{/admin/users/#{forum_member_id}/groups/#{extra_role.role_id}})
  end

  test "update_roles retries on 429 response" do
    forum_member_id = 1
    username = "fluffy_panda"

    user = create(:user, forum_member_id: forum_member_id)
    unit = create(:unit)
    create(:assignment, user: user, unit: unit)
    missing_role = create(:unit_forum_role, unit: unit)

    stub_user_request(forum_member_id, username: username, groups: [])
    stub_request(:post, %r{/admin/users/#{forum_member_id}/groups})
      .to_return({status: 429}, {status: 200})

    expected_roles = user.forum_role_ids(:discourse)
    DiscourseService.new(forum_member_id).user.update_roles(expected_roles)

    assert_requested(:post, %r{/admin/users/#{forum_member_id}/groups}, times: 2) do |req|
      req.body = {group_id: missing_role.role_id}
    end
  end

  test "update_roles throws on 500 response" do
    forum_member_id = 1
    username = "fluffy_panda"

    user = create(:user, forum_member_id: forum_member_id)
    unit = create(:unit)
    create(:assignment, user: user, unit: unit)
    create(:unit_forum_role, unit: unit)

    stub_user_request(forum_member_id, username: username, groups: [])
    stub_request(:post, %r{/admin/users/#{forum_member_id}/groups})
      .to_return(status: 500)

    expected_roles = user.forum_role_ids(:discourse)

    assert_raises Faraday::ServerError do
      DiscourseService.new(forum_member_id).user.update_roles(expected_roles)
    end
  end

  test "create_topic uses username in header" do
    forum_member_id = 1
    username = "fluffy_panda"

    create(:user, forum_member_id: forum_member_id)

    stub_user_request(forum_member_id, username: username)
    stub_request(:post, %r{/posts.json})

    DiscourseService.new(forum_member_id).user.create_topic(1, "title", "body")

    assert_requested(:post, %r{/posts.json},
      headers: {"Api-Username" => "fluffy_panda"})
  end

  test "create_topic uses allow-listed kwargs if provided" do
    forum_member_id = 1
    username = "fluffy_panda"

    create(:user, forum_member_id: forum_member_id)

    stub_user_request(forum_member_id, username: username)
    stub_request(:post, %r{/posts.json})

    DiscourseService.new(forum_member_id).user.create_topic(1, "title", "body",
      external_id: 9)

    assert_requested(:post, %r{/posts.json},
      body: {category: 1, title: "title", raw: "body", external_id: 9})
  end
end
