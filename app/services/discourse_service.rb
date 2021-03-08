class DiscourseService
  include HTTParty
  base_uri ENV['DISCOURSE_BASE_URL']
  headers 'Api-Key' => ENV['DISCOURSE_API_KEY']
  headers 'Api-Username' => 'system'

  def get_groups()
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
  end

  private

  def get_discourse_user(user)
    discourse_user_id = user.discourse_forum_member_id
    url = "/admin/users/#{discourse_user_id}.json"
    response = self.class.get(url)
  end
end
