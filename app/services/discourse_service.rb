class DiscourseService
  class NoLinkedAccountError < StandardError; end

  def initialize
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

  def update_user_display_name(forum_member_id, display_name)
    discourse_user = get_discourse_user(forum_member_id)
    username = discourse_user["username"]

    path = "/u/#{username}"
    body = {name: display_name}
    @conn.put(path, body)
  end

  def update_user_roles(forum_member_id, expected_roles)
    discourse_user = get_discourse_user(forum_member_id)
    current_roles = select_assigned_role_ids(discourse_user["groups"] || [])

    roles_to_delete = current_roles.difference(expected_roles)
    roles_to_delete.each { |role_id| delete_role(forum_member_id, role_id) }

    roles_to_add = expected_roles.difference(current_roles)
    roles_to_add.each { |role_id| add_role(forum_member_id, role_id) }
  end

  private

  def get_discourse_user(forum_member_id)
    path = "/admin/users/#{forum_member_id}.json"
    response = @conn.get(path)
    response.body
  end

  def select_assigned_role_ids(groups)
    groups.reject { |group| group["automatic"] } # exclude trust groups
      .collect { |group| group["id"] }
  end

  def delete_role(forum_member_id, role_id)
    path = "/admin/users/#{forum_member_id}/groups/#{role_id}"
    @conn.delete(path)
  end

  def add_role(forum_member_id, role_id)
    path = "/admin/users/#{forum_member_id}/groups"
    body = {group_id: role_id}
    @conn.post(path, body)
  end
end
