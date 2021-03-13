require 'test_helper'

BASE_URL = ENV['DISCOURSE_BASE_URL']

class DiscourseServiceTest < ActiveSupport::TestCase
  def stub_username_request(user_id, username)
    response_body = { username: username }
    stub_request(:get, "#{BASE_URL}/admin/users/#{user_id}.json")
      .to_return(body: response_body.to_json)
  end

  test "update_display_name uses user.short_name" do
    discourse_user_id = 1
    username = 'fluffy_panda'

    user = create(:user, last_name: 'Panda', discourse_forum_member_id: discourse_user_id)
    stub_username_request(discourse_user_id, username)

    request_body = { name: user.short_name }
    stub_update = stub_request(:put, "#{BASE_URL}/u/#{username}")
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
end
