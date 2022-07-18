module UsersHelper
  def discourse_user_url(user)
    base_url = Rails.configuration.endpoints[:discourse][:base_url][:external]
    "#{base_url}/user-by-id/#{user.forum_member_id}/summary"
  end

  def v2_user_url(user)
    base_url = Rails.configuration.endpoints[:personnel_v2_app][:base_url][:external]
    "#{base_url}/#members/#{user.id}"
  end
end
