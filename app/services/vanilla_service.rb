class VanillaService
  class NoLinkedAccountError < StandardError; end

  def initialize
    url = "#{ENV["VANILLA_BASE_URL"]}/api/v2"
    @conn = Faraday.new(url) do |conn|
      conn.authorization(:Bearer, ENV["VANILLA_API_KEY"])
      conn.request :json
      conn.response :raise_error
      conn.response :json, content_type: /\bjson$/
      conn.response :logger, nil, {headers: false, bodies: true}
    end
  end

  def get_roles
    response = @conn.get("/roles")

    response.each_with_object({}) do |role, accum|
      accum[role["roleID"]] = role["name"]
    end
  end

  def update_user_display_name(user)
    vanilla_user_id = user.vanilla_forum_member_id
    raise NoLinkedAccountError unless vanilla_user_id

    sanitized_name = user.short_name.delete("/")
    path = "users/#{vanilla_user_id}"
    body = {name: sanitized_name}
    @conn.patch(path, body)
  end

  def update_user_roles(user)
    vanilla_user_id = user.vanilla_forum_member_id
    raise NoLinkedAccountError unless vanilla_user_id

    expected_roles = user.forum_role_ids(:vanilla)
    path = "users/#{vanilla_user_id}"
    body = {roleID: expected_roles}
    @conn.patch(path, body)
  end
end
