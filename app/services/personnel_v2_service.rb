class PersonnelV2Service
  def initialize
    url = ENV["V2_API_BASE_URL"]
    puts url
    @conn = Faraday.new(url) do |conn|
      conn.headers = {
        "X-Admin-Api-Key" => ENV["V2_ADMIN_API_KEY"]
      }
      conn.request :json
      conn.response :json
    end
  end

  def update_coat(user_id)
    @conn.post("/members/#{user_id}/coat")
  end
end
