require "test_helper"

class DiscourseWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV["DISCOURSE_WEBHOOKS_SECRET"] = "test"

    @discourse_user_id = 10
    @body = {
      "user": {
        "id": @discourse_user_id,
        "username": "soandso",
        "name": "Pvt. Soandso",
        "email": "so@so.com"
      }
    }

    @headers = {
      "X-Discourse-Event-Type": "user",
      "X-Discourse-Event": "user_activated",
      "X-Discourse-Event-Signature": sign(@body)
    }

    @subject = create(:user, email: "so@so.com")
  end

  test "should throw 401 if missing signature" do
    headers = @headers.except("X-Discourse-Event-Signature".to_sym)
    post discourse_webhooks_url, params: @body, headers: headers, as: :json
    assert_response :unauthorized
    assert_nil User.find_by_discourse_forum_member_id(@discourse_user_id)
  end

  test "should throw 401 if signature invalid" do
    headers = @headers.merge({"X-Discourse-Event-Signature": "invalidsignature"})
    post discourse_webhooks_url, params: @body, headers: headers, as: :json
    assert_response :unauthorized
    assert_nil User.find_by_discourse_forum_member_id(@discourse_user_id)
  end

  test "should do nothing if event header is not user_activated" do
    headers = @headers.merge({"X-Discourse-Event": "user_updated"})
    post discourse_webhooks_url, params: @body, headers: headers, as: :json
    assert_response :no_content
    assert_nil User.find_by_discourse_forum_member_id(@discourse_user_id)
  end

  test "should update user's discourse_forum_member_id" do
    post discourse_webhooks_url, params: @body, headers: @headers, as: :json
    assert_response :no_content
    assert_equal @subject, User.find_by_discourse_forum_member_id(@discourse_user_id)
  end

  test "should throw if another user already has that discourse_forum_member_id" do
    other_subject = create(:user, discourse_forum_member_id: @discourse_user_id)
    assert_raises(ActiveRecord::RecordInvalid) do
      post discourse_webhooks_url, params: @body, headers: @headers, as: :json
    end
    assert_equal other_subject, User.find_by_discourse_forum_member_id(@discourse_user_id)
  end

  private

  def sign(body)
    "sha256=#{OpenSSL::HMAC.hexdigest("sha256", ENV["DISCOURSE_WEBHOOKS_SECRET"], body.to_json)}"
  end
end
