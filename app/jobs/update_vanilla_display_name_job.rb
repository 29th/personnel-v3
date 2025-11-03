class UpdateVanillaDisplayNameJob < ApplicationJob
  queue_as :default

  def perform(user)
    return unless user.vanilla_forum_member_id.present?

    vanilla_service = VanillaService.new(user.vanilla_forum_member_id)
    vanilla_service.user.update_display_name(user.short_name)
  end
end
