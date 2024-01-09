class DiscourseService
  attr_reader :user

  def initialize(forum_member_id = nil)
    config = Rails.configuration.endpoints[:discourse]
    url = config[:base_url][:internal]
    @conn = Faraday.new(url) do |conn|
      conn.headers = {
        "Api-Key" => config[:api_key],
        "Api-Username" => "system"
      }
      conn.request :json
      conn.response :raise_error # Must be before :retry
      conn.request :retry, {
        retry_statuses: [429],
        methods: %i[post delete],
        max: 3,
        interval: 0.05,
        interval_randomness: 0.5,
        backoff_factor: 2
      }
      conn.response :json, content_type: /\bjson$/
      conn.response :logger, nil, {headers: false, bodies: true} unless Rails.env.test?
    end

    @user = DiscourseUser.new(@conn, forum_member_id) if forum_member_id
  end

  def roles
    groups = {}
    current_page = 0
    total_group_count = nil
    max_loop_requests = 10 # safety cap

    while (groups.size.zero? || groups.size < total_group_count) && current_page < max_loop_requests
      query = {page: current_page}
      response = @conn.get("/groups.json", query)

      groups = response.body["groups"].each_with_object(groups) do |role, accum|
        accum[role["id"]] = role["name"]
      end

      total_group_count = response.body["total_rows_groups"]
      current_page += 1
    end

    groups
  end

  class DiscourseUser
    def initialize(conn, forum_member_id)
      @conn = conn
      @forum_member_id = forum_member_id
    end

    def username
      user_data["username"]
    end

    def update_display_name(display_name)
      path = "/u/#{username}"
      body = {name: display_name}
      @conn.put(path, body)
    end

    def update_roles(expected_roles)
      current_roles = select_assigned_role_ids(user_data["groups"] || [])

      roles_to_delete = current_roles.difference(expected_roles)
      roles_to_delete.each { |role_id| delete_role(role_id) }

      roles_to_add = expected_roles.difference(current_roles)
      roles_to_add.each { |role_id| add_role(role_id) }
    end

    def linked_users
      ips_with_users = get_user_ips
        .map do |ip|
          linked_users = get_users_by_ip(ip)
          {ip: ip, users: linked_users}
        end
      key_ips_by_user(ips_with_users)
    end

    def email
      @email ||= begin
        path = "/u/#{username}/emails.json"
        response = @conn.get(path)

        response.body["email"]
      end
    end

    private

    def user_data
      @user_data ||= begin
        raise ArgumentError.new("Missing forum_member_id in initialization") unless @forum_member_id
        path = "/admin/users/#{@forum_member_id}.json"
        response = @conn.get(path)
        response.body
      end
    end

    def select_assigned_role_ids(groups)
      # exclude trust groups
      groups.reject { |group| group["automatic"] }
        .collect { |group| group["id"] }
    end

    def delete_role(role_id)
      raise ArgumentError.new("Missing forum_member_id in initialization") unless @forum_member_id
      path = "/admin/users/#{@forum_member_id}/groups/#{role_id}"
      @conn.delete(path)
    end

    def add_role(role_id)
      raise ArgumentError.new("Missing forum_member_id in initialization") unless @forum_member_id
      path = "/admin/users/#{@forum_member_id}/groups"
      body = {group_id: role_id}
      @conn.post(path, body)
    end

    def get_user_ips
      user_data
        .values_at("ip_address", "registration_ip_address")
        .compact_blank
        .uniq
    end

    def get_users_by_ip(ip)
      path = "/admin/users/list.json"
      response = @conn.get(path, {ip: ip})
      response.body.map { |user| user.slice("id", "username") }
    end

    def key_ips_by_user(ips)
      users = ips.each_with_object({}) do |row, memo|
        row[:users].each do |user|
          id, username = user.values_at("id", "username")
          memo[id] ||= {id: id, username: username, ips: [], forum: :discourse}
          memo[id][:ips] << row[:ip]
        end
      end
      users.values
    end
  end
end
