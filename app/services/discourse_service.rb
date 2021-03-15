class DiscourseService
  class NoLinkedAccountError < StandardError; end

  include HTTParty
  base_uri ENV['DISCOURSE_BASE_URL']
  headers 'Api-Key' => ENV['DISCOURSE_API_KEY']
  headers 'Api-Username' => 'system'
  headers 'Content-type' => 'application/json'
  format :json

  def get_roles()
    groups = {}
    current_page = 0
    total_group_count = nil
    max_loop_requests = 10 # safety cap

    while (groups.size.zero? || groups.size < total_group_count) && current_page < max_loop_requests
      query = { page: current_page }
      response = self.class.get('/groups.json', query: query)
      return if response.body.nil? || response.body.empty?

      groups = response['groups'].each_with_object(groups) do |role, accum|
        accum[role['id']] = role['name']
      end

      total_group_count = response['total_rows_groups']
      current_page += 1
    end

    groups
  end

  def update_user_display_name(user)
    discourse_user = get_discourse_user(user)
    username = discourse_user['username']
    puts discourse_user['a']

    path = "/u/#{username}"
    body = { name: user.short_name }
    response = self.class.put(path, body: body.to_json)
    raise HTTParty::ResponseError, "Failed to update display name for user #{username}" if response.code >= 400
  end

  def update_user_roles(user)
    discourse_user = get_discourse_user(user)
    discourse_user_id = user.discourse_forum_member_id
    expected_roles = user.forum_role_ids(:discourse)
    current_roles = select_assigned_role_ids(discourse_user['groups'])

    roles_to_delete = current_roles.difference(expected_roles)
    roles_to_delete.each { |role_id| delete_role(discourse_user_id, role_id) }

    roles_to_add = expected_roles.difference(current_roles)
    roles_to_add.each { |role_id| add_role(discourse_user_id, role_id) }
  end

  private

  def get_discourse_user(user)
    discourse_user_id = user.discourse_forum_member_id
    raise NoLinkedAccountError unless discourse_user_id

    path = "/admin/users/#{discourse_user_id}.json"
    response = self.class.get(path)
    raise NoLinkedAccountError if response.code == 404

    response
  end

  def select_assigned_role_ids(groups)
    groups.reject { |group| group['automatic'] } # exclude trust groups
          .collect { |group| group['id'] }
  end

  def delete_role(discourse_user_id, role_id)
    path = "/admin/users/#{discourse_user_id}/groups/#{role_id}"
    response = self.class.delete(path)
    raise HTTParty::ResponseError, "Failed to delete role #{role_id}" if response.code >= 400
  end

  def add_role(discourse_user_id, role_id)
    path = "/admin/users/#{discourse_user_id}/groups"
    body = { group_id: role_id }
    response = self.class.post(path, body: body.to_json)
    raise HTTParty::ResponseError, "Failed to add role #{role_id} (#{response.code})" if response.code >= 400
  end
end
