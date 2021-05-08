class DiscourseService
  class NoLinkedAccountError < StandardError; end

  def initialize
    url = ENV["DISCOURSE_BASE_URL"]
    @conn = Faraday.new(url) do |conn|
      conn.headers = {
        "Api-Key" => ENV["DISCOURSE_API_KEY"],
        "Api-Username" => "system"
      }
      conn.request :json
      conn.response :raise_error
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
  end

  def get_roles
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

  def update_user_display_name(user)
    discourse_user = get_discourse_user(user)
    username = discourse_user["username"]

    path = "/u/#{username}"
    body = {name: user.short_name}
    @conn.put(path, body)
  end

  def update_user_roles(user)
    discourse_user = get_discourse_user(user)
    discourse_user_id = user.forum_member_id
    expected_roles = user.forum_role_ids(:discourse)
    current_roles = select_assigned_role_ids(discourse_user["groups"] || [])

    roles_to_delete = current_roles.difference(expected_roles)
    roles_to_delete.each { |role_id| delete_role(discourse_user_id, role_id) }

    roles_to_add = expected_roles.difference(current_roles)
    roles_to_add.each { |role_id| add_role(discourse_user_id, role_id) }
  end

  private

  def get_discourse_user(user)
    discourse_user_id = user.forum_member_id
    raise NoLinkedAccountError unless discourse_user_id

    path = "/admin/users/#{discourse_user_id}.json"
    response = @conn.get(path)
    raise NoLinkedAccountError if response.status == 404

    response.body
  end

  def select_assigned_role_ids(groups)
    groups.reject { |group| group["automatic"] } # exclude trust groups
      .collect { |group| group["id"] }
  end

  def delete_role(discourse_user_id, role_id)
    path = "/admin/users/#{discourse_user_id}/groups/#{role_id}"
    @conn.delete(path)
  end

  def add_role(discourse_user_id, role_id)
    path = "/admin/users/#{discourse_user_id}/groups"
    body = {group_id: role_id}
    @conn.post(path, body)
  end
end
