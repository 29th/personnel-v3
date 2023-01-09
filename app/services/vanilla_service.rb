class VanillaService
  class NoLinkedAccountError < StandardError; end

  def initialize
    config = Rails.configuration.endpoints[:vanilla]
    url = "#{config[:base_url][:internal]}/api/v2"
    @conn = Faraday.new(url) do |conn|
      conn.request :authorization, "Bearer", config[:api_key]
      conn.request :json
      conn.response :raise_error
      conn.response :json, content_type: /\bjson$/
      conn.response :logger, nil, {headers: false, bodies: true} unless Rails.env.test?
    end
  end

  def get_username(forum_member_id)
    path = "users/#{forum_member_id}"
    response = @conn.get(path)
    response.body["name"]
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

  def get_linked_users(forum_member_id)
    path = "users/#{forum_member_id}"
    response = @conn.get(path)
    return unless response.body["ips"].present?

    rows = response.body["ips"].map { |row| row.deep_transform_keys(&:underscore) }
    key_ips_by_user(rows)
  end

  private

  # Invert structure to be keyed by user
  def key_ips_by_user(rows)
    users = rows.each_with_object({}) do |row, memo|
      row["other_users"].each do |other_user|
        name = other_user["name"]
        user_id = other_user["user_id"]
        memo[name] ||= {username: name, user_id: user_id, ips: [],
                        forum: :vanilla}
        memo[name][:ips] << row["ip"]
      end
    end
    users.values
  end
end
