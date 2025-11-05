class UpdateDiscourseRolesJob < ApplicationJob
  queue_as :default
  retry_on Faraday::Error

  def perform(user)
    return unless user.forum_member_id.present?

    discourse_service = DiscourseService.new(user.forum_member_id)
    expected_roles = user.forum_role_ids(:discourse)
    discourse_service.user.update_roles(expected_roles)
  end
end
