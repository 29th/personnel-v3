Rails.application.config.middleware.use OmniAuth::Builder do
  provider :steam, ENV.fetch('STEAM_WEB_API_KEY')
end
