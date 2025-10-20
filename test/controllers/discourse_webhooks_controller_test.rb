require "test_helper"

class DiscourseWebhooksControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @discourse_user_id = 10
    @body = {
      user: {
        id: @discourse_user_id,
        username: "soandso",
        name: "Pvt. Soandso",
        email: "so@so.com",
        user_option: {
          timezone: "Europe/London"
        }
      }
    }

    @headers = {
      "X-Discourse-Event-Type": "user",
      "X-Discourse-Event-Signature": sign(@body)
    }
    clear_enqueued_jobs
    @subject = create(:user, email: "so@so.com")
  end

  test "user_activated should return 401 if missing signature" do
    headers = @headers
      .merge({"X-Discourse-Event": "user_activated"})
      .except(:"X-Discourse-Event-Signature")

    post discourse_webhook_user_activated_url, params: @body, headers: headers, as: :json
    assert_response :unauthorized
    assert_nil User.find_by_forum_member_id(@discourse_user_id)
  end

  test "user_activated should return 401 if signature invalid" do
    headers = @headers.merge({"X-Discourse-Event": "user_activated",
                              "X-Discourse-Event-Signature": "invalidsignature"})

    post discourse_webhook_user_activated_url, params: @body, headers: headers, as: :json
    assert_response :unauthorized
    assert_nil User.find_by_forum_member_id(@discourse_user_id)
  end

  test "should do nothing if event header is not user_activated" do
    headers = @headers.merge({"X-Discourse-Event": "other_event"})
    post discourse_webhook_user_activated_url, params: @body, headers: headers, as: :json
    assert_response :no_content
    assert_nil User.find_by_forum_member_id(@discourse_user_id)
  end

  test "user_activated should update user's forum_member_id, forum roles, and display name" do
    headers = @headers.merge({"X-Discourse-Event": "user_activated"})

    assert_enqueued_with(job: UpdateDiscourseDisplayNameJob, args: [@subject]) do
      assert_enqueued_with(job: UpdateDiscourseRolesJob, args: [@subject]) do
        post discourse_webhook_user_activated_url, params: @body, headers: headers, as: :json
      end
    end

    assert_response :no_content
    assert_equal @subject, User.find_by_forum_member_id(@discourse_user_id)
  end

  test "user_activated should return 422 if another user already has that forum_member_id" do
    headers = @headers.merge({"X-Discourse-Event": "user_activated"})
    other_subject = create(:user, forum_member_id: @discourse_user_id)
    post discourse_webhook_user_activated_url, params: @body, headers: headers, as: :json
    assert_response :unprocessable_entity
    assert_equal other_subject, User.find_by_forum_member_id(@discourse_user_id)
  end

  test "user_activated should return 404 if no user found with that email" do
    body = @body.deep_merge({user: {email: "new@user.com"}})
    headers = @headers.merge({"X-Discourse-Event": "user_activated",
                              "X-Discourse-Event-Signature": sign(body)})

    post discourse_webhook_user_activated_url, params: body, headers: headers, as: :json
    assert_response :not_found
    assert_nil User.find_by_forum_member_id(@discourse_user_id)
  end

  test "user_updated should update matching user's email and time_zone" do
    subject = create(:user, forum_member_id: @discourse_user_id)
    body = @body.deep_merge({
      user: {
        email: "new@email.com",
        user_option: {timezone: "Europe/London"}
      }
    })
    headers = @headers.merge({"X-Discourse-Event": "user_updated",
                              "X-Discourse-Event-Signature": sign(body)})

    post discourse_webhook_user_updated_url, params: body, headers: headers, as: :json
    assert_response :no_content
    subject.reload
    assert_equal "new@email.com", subject.email
    assert_equal "Europe/London", subject.time_zone
  end

  test "user_updated should return 404 if no user found with that forum_member_id" do
    headers = @headers.merge({"X-Discourse-Event": "user_updated"})
    post discourse_webhook_user_updated_url, params: @body, headers: headers, as: :json
    assert_response :not_found
  end

  test "user_updated should return 422 if time zone is invalid" do
    create(:user, forum_member_id: @discourse_user_id)
    body = @body.deep_merge({user: {user_option: {timezone: "Fake/Zone"}}})
    headers = @headers.merge({"X-Discourse-Event": "user_updated",
                              "X-Discourse-Event-Signature": sign(body)})

    post discourse_webhook_user_updated_url, params: body, headers: headers, as: :json
    assert_response :unprocessable_entity
  end

  private

  def sign(body)
    webhooks_secret = Settings.discourse.webhooks_secret
    "sha256=#{OpenSSL::HMAC.hexdigest("sha256", webhooks_secret, body.to_json)}"
  end
end
