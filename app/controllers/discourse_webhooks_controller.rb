class DiscourseWebhooksController < ApplicationController
  SECRET_KEY = ENV["DISCOURSE_WEBHOOKS_SECRET"]
  before_action :verify_event_type!
  before_action :verify_webhook_token!

  def receive
    discourse_user_id = params["user"]["id"]
    discourse_email = params["user"]["email"]

    matching_user = User.find_by_email(discourse_email)
    matching_user&.update!(discourse_forum_member_id: discourse_user_id)

    head :no_content
  end

  private

  def verify_event_type!
    head :no_content unless request.headers["X-Discourse-Event"] == "user_activated"
  end

  def verify_webhook_token!
    event_signature = request.headers["X-Discourse-Event-Signature"]
    return head :unauthorized unless event_signature

    raw_post = request.raw_post
    calculated_hmac = "sha256=#{OpenSSL::HMAC.hexdigest("sha256", SECRET_KEY, raw_post)}"
    verified = ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, event_signature)

    head :unauthorized unless verified
  end
end
