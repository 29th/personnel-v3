class PersonnelV2Service
  def initialize
    url = Settings.personnel_v2_api.base_url.internal
    puts url
    @conn = Faraday.new(url) do |conn|
      conn.headers = {
        "X-Admin-Api-Key" => Settings.personnel_v2_api.api_key
      }
      conn.request :json
      conn.response :json
      conn.response :logger, nil, {headers: false, bodies: true} unless Rails.env.test?
    end
  end

  def update_coat(user_id)
    @conn.post("/members/#{user_id}/coat")
  end
end
