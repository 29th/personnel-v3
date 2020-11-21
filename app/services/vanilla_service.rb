class VanillaService
  include HTTParty
  # base_uri ENV['VANILLA_BASE_URL'] + '/api/v2'
  base_uri 'http://forums/api/v2'
  headers 'Authorization' => "Bearer #{ENV['VANILLA_API_KEY']}"

  def get_roles()
    response = self.class.get('/roles')
    return if response.body.nil? || response.body.empty?

    response.reduce({}) do |accum, role|
      accum[role['roleID']] = role['name']
      accum
    end
  end
end
