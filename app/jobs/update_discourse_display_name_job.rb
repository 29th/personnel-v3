class UpdateDiscourseDisplayNameJob < ApplicationJob
  queue_as :default
  retry_on Faraday::Error

  def perform(user)
    return unless user.forum_member_id.present?

    discourse_service = DiscourseService.new(user.forum_member_id)
    discourse_service.user.update_display_name(user.short_name)
  end
end
