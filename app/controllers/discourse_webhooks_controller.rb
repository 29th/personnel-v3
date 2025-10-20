class DiscourseWebhooksController < ApplicationController
  SECRET_KEY = Settings.discourse.webhooks_secret
  before_action :verify_webhook_token
  skip_before_action :verify_authenticity_token

  # When a forum account is activated (email confirmed), check the
  # personnel database for an existing user with that email (from
  # when we used an earlier forum). If there's a match, link the
  # user to this forum account.
  def user_activated
    discourse_user_id = params["user"]["id"]
    discourse_email = params["user"]["email"].strip.downcase

    matching_user = User.find_by_email!(discourse_email)
    matching_user.update!(forum_member_id: discourse_user_id)
    UpdateDiscourseDisplayNameJob.perform_later(matching_user)
    UpdateDiscourseRolesJob.perform_later(matching_user)

    head :no_content
  rescue ActiveRecord::RecordNotFound
    head :not_found
  rescue ActiveRecord::RecordInvalid
    head :unprocessable_entity
  end

  # When a forum user updates their profile, update the email and
  # time_zone fields in the personnel database, if they've changed.
  def user_updated
    forum_member_id = params["user"]["id"]
    email = params["user"]["email"]
    time_zone = params["user"]["user_option"]["timezone"]

    matching_user = User.find_by_forum_member_id!(forum_member_id)
    matching_user.update!(email: email, time_zone: time_zone)

    head :no_content
  rescue ActiveRecord::RecordNotFound
    head :not_found
  rescue ActiveRecord::RecordInvalid
    head :unprocessable_entity
  end

  private

  def verify_webhook_token
    event_signature = request.headers["X-Discourse-Event-Signature"]
    return head :unauthorized unless event_signature

    raw_post = request.raw_post
    calculated_hmac = "sha256=#{OpenSSL::HMAC.hexdigest("sha256", SECRET_KEY, raw_post)}"
    verified = ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, event_signature)

    head :unauthorized unless verified
  end
end
