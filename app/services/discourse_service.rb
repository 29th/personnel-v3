class DiscourseService
  include HTTParty
  base_uri ENV['DISCOURSE_BASE_URL']
  headers 'Api-Key' => ENV['DISCOURSE_API_KEY']
  headers 'Api-Username' => 'system'

  def get_roles()
    response = self.class.get('/groups.json')
    return if response.body.nil? || response.body.empty?

    response['groups'].reduce({}) do |accum, role|
      accum[role['id']] = role['name']
      accum
    end
  end
end
