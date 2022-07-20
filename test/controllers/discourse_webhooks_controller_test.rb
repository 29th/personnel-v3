require "test_helper"

class DiscourseWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @discourse_user_id = 10
    @body = {
      user: {
        id: @discourse_user_id,
        username: "soandso",
        name: "Pvt. Soandso",
        email: "so@so.com"
      }
    }

    @headers = {
      "X-Discourse-Event-Type": "user",
      "X-Discourse-Event": "user_activated",
      "X-Discourse-Event-Signature": sign(@body)
    }

    @subject = create(:user, email: "so@so.com")

    ActionController::Base.allow_forgery_protection = true
  end

  teardown do
    ActionController::Base.allow_forgery_protection = false
  end

  test "should return 401 if missing signature" do
    headers = @headers.except(:"X-Discourse-Event-Signature")
    post discourse_webhooks_url, params: @body, headers: headers, as: :json
    assert_response :unauthorized
    assert_nil User.find_by_forum_member_id(@discourse_user_id)
  end

  test "should return 401 if signature invalid" do
    headers = @headers.merge({"X-Discourse-Event-Signature": "invalidsignature"})
    post discourse_webhooks_url, params: @body, headers: headers, as: :json
    assert_response :unauthorized
    assert_nil User.find_by_forum_member_id(@discourse_user_id)
  end

  test "should do nothing if event header is not user_activated" do
    headers = @headers.merge({"X-Discourse-Event": "user_updated"})
    post discourse_webhooks_url, params: @body, headers: headers, as: :json
    assert_response :no_content
    assert_nil User.find_by_forum_member_id(@discourse_user_id)
  end

  test "should update user's forum_member_id, forum roles, and display name" do
    methods_called = []
    User.stub_any_instance(:update_forum_display_name, -> { methods_called << :update_forum_display_name }) do
      User.stub_any_instance(:update_forum_roles, -> { methods_called << :update_forum_roles }) do
        post discourse_webhooks_url, params: @body, headers: @headers, as: :json
      end
    end

    assert_response :no_content
    assert_equal @subject, User.find_by_forum_member_id(@discourse_user_id)

    assert_includes methods_called, :update_forum_display_name
    assert_includes methods_called, :update_forum_roles
  end

  test "should return 422 if another user already has that forum_member_id" do
    other_subject = create(:user, forum_member_id: @discourse_user_id)
    post discourse_webhooks_url, params: @body, headers: @headers, as: :json
    assert_response :unprocessable_entity
    assert_equal other_subject, User.find_by_forum_member_id(@discourse_user_id)
  end

  test "should return 404 if no user found with that email" do
    body = @body.deep_merge({user: {email: "new@user.com"}})
    headers = @headers.merge({"X-Discourse-Event-Signature": sign(body)})
    post discourse_webhooks_url, params: body, headers: headers, as: :json
    assert_response :not_found
    assert_nil User.find_by_forum_member_id(@discourse_user_id)
  end

  private

  def sign(body)
    webhooks_secret = Rails.configuration.endpoints[:discourse][:webhooks_secret]
    "sha256=#{OpenSSL::HMAC.hexdigest("sha256", webhooks_secret, body.to_json)}"
  end
end
