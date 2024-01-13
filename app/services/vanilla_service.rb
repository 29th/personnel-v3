class VanillaService
  attr_reader :user

  def initialize(forum_member_id = nil)
    config = Rails.configuration.endpoints[:vanilla]
    url = "#{config[:base_url][:internal]}/api/v2"
    @conn = Faraday.new(url) do |conn|
      conn.request :authorization, "Bearer", config[:api_key]
      conn.request :json
      conn.response :raise_error
      conn.response :json, content_type: /\bjson$/
      conn.response :logger, nil, {headers: false, bodies: true} unless Rails.env.test?
    end

    @user = VanillaUser.new(@conn, forum_member_id) if forum_member_id
  end

  def roles
    response = @conn.get("/roles")

    response.each_with_object({}) do |role, accum|
      accum[role["roleID"]] = role["name"]
    end
  end

  class VanillaUser
    def initialize(conn, forum_member_id)
      @conn = conn
      @forum_member_id = forum_member_id
    end

    def username
      user_data["name"]
    end

    def update_display_name(display_name)
      sanitized_name = display_name.delete("/")
      path = "users/#{@forum_member_id}"
      body = {name: sanitized_name}
      @conn.patch(path, body)
    end

    def update_roles(expected_roles)
      path = "users/#{@forum_member_id}"
      body = {roleID: expected_roles}
      @conn.patch(path, body)
    end

    def linked_users
      raise Faraday::Error.new("response missing IP addresses - vanilla plugin may be disabled") unless user_data.has_key?("ips")

      rows = user_data["ips"].map { |row| row.deep_transform_keys(&:underscore) }
      key_ips_by_user(rows)
    end

    private

    def user_data
      @user_data ||= begin
        path = "users/#{@forum_member_id}"
        response = @conn.get(path)
        response.body
      end
    end

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
end
