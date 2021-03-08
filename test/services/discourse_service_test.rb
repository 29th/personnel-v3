require 'test_helper'

class DiscourseServiceTest < ActiveSupport::TestCase
  test "updates display name" do
    discourse_user_id = 1
    username = 'fluffy_panda'
    pvt = create(:rank, abbr: 'Pvt.')
    user = create(:user, last_name: 'Panda', rank: pvt, discourse_forum_member_id: discourse_user_id)
    user_response_body = "{\"username\": \"#{username}\"}"

    stub_get = stub_request(:get, "#{ENV['DISCOURSE_BASE_URL']}/admin/users/#{discourse_user_id}.json")
               .to_return(body: user_response_body)
    stub_update = stub_request(:put, "#{ENV['DISCOURSE_BASE_URL']}/u/#{username}")

    DiscourseService.new().update_user_display_name(user)

    assert_requested(stub_get)
    assert_requested(stub_update)
  end
end
