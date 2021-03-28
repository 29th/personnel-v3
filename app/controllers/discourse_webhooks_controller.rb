class DiscourseWebhooksController < ApplicationController
  SECRET_KEY = ENV["DISCOURSE_WEBHOOKS_SECRET"]
  skip_before_action :verify_authenticity_token, if: :valid_webhook_token?

  def receive
    return if request.headers["X-Discourse-Event"] != "user_activated"

    discourse_user_id = params["user"]["id"]
    discourse_email = params["user"]["email"]

    matching_user = User.find_by_email(discourse_email)
    matching_user&.update(discourse_forum_member_id: discourse_user_id)
  end

  private

  def valid_webhook_token?
    raw_post = request.raw_post
    event_signature = request.headers["X-Discourse-Event-Signature"]
    calculated_hmac = "sha256=#{OpenSSL::HMAC.hexdigest("sha256", SECRET_KEY, raw_post)}"
    ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, event_signature)
  end
end
