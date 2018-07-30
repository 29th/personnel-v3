Rails.application.config.middleware.use OmniAuth::Builder do
  provider :steam, Rails.application.credentials.steam_web_api_key
end
