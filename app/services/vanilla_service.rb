class VanillaService
  class NoLinkedAccountError < StandardError; end

  include HTTParty
  base_uri "#{ENV['VANILLA_BASE_URL']}/api/v2"
  headers 'Authorization' => "Bearer #{ENV['VANILLA_API_KEY']}"
  headers 'Content-type' => 'application/json'
  format :json

  def get_roles()
    response = self.class.get('/roles')
    return if response.body.nil? || response.body.empty?

    response.reduce({}) do |accum, role|
      accum[role['roleID']] = role['name']
      accum
    end
  end

  def update_user_display_name(user)
    vanilla_user_id = user.forum_member_id
    raise NoLinkedAccountError unless vanilla_user_id

    sanitized_name = user.short_name.gsub('/', '')
    path = "/users/#{vanilla_user_id}"
    body = { name: sanitized_name }
    response = self.class.patch(path, body: body.to_json)
    raise HTTParty::ResponseError, "Failed to update display name for user #{vanilla_user_id}" if response.code >= 400
  end

  def update_user_roles(user)
    vanilla_user_id = user.forum_member_id
    raise NoLinkedAccountError unless vanilla_user_id

    expected_roles = user.forum_role_ids(:vanilla)
    path = "/users/#{vanilla_user_id}"
    body = { roleID: expected_roles }
    response = self.class.patch(path, body: body.to_json)
    raise HTTParty::ResponseError, "Failed to update role sfor user #{vanilla_user_id}" if response.code >= 400
  end
end
