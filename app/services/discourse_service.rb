class DiscourseService
  include HTTParty
  base_uri ENV['DISCOURSE_BASE_URL']
  headers 'Api-Key' => ENV['DISCOURSE_API_KEY']
  headers 'Api-Username' => 'system'
  MAX_LOOP_REQUESTS = 10 # safety cap

  def get_roles()
    groups = {}
    current_page = 0
    total_group_count = nil

    while (groups.size.zero? || groups.size < total_group_count) && current_page < MAX_LOOP_REQUESTS
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
end
