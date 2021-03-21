class PersonnelV2Service
  include HTTParty
  base_uri ENV["V2_API_BASE_URL"]
  headers "X-Admin-Api-Key" => ENV["V2_ADMIN_API_KEY"]

  def update_coat(user_id)
    self.class.post("/members/#{user_id}/coat")
  end
end
