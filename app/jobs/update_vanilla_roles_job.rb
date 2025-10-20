class UpdateVanillaRolesJob < ApplicationJob
  queue_as :default

  def perform(user)
    return unless user.vanilla_forum_member_id.present?

    vanilla_service = VanillaForumService.new(user.vanilla_forum_member_id)
    expected_roles = user.forum_roles(:vanilla)
    vanilla_service.user.update_roles(expected_roles)
  end
end
