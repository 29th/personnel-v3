class VanillaService
  class NoLinkedAccountError < StandardError; end

  def initialize
    url = "#{ENV["VANILLA_BASE_URL"]}/api/v2"
    @conn = Faraday.new(url) do |conn|
      conn.request :authorization, "Bearer", ENV["VANILLA_API_KEY"]
      conn.request :json
      conn.response :raise_error
      conn.response :json, content_type: /\bjson$/
      conn.response :logger, nil, {headers: false, bodies: true} unless Rails.env.test?
    end
  end

  def get_roles
    response = @conn.get("/roles")

    response.each_with_object({}) do |role, accum|
      accum[role["roleID"]] = role["name"]
    end
  end

  def update_user_display_name(forum_member_id, display_name)
    sanitized_name = display_name.delete("/")
    path = "users/#{forum_member_id}"
    body = {name: sanitized_name}
    @conn.patch(path, body)
  end

  def update_user_roles(forum_member_id, expected_roles)
    path = "users/#{forum_member_id}"
    body = {roleID: expected_roles}
    @conn.patch(path, body)
  end
end
