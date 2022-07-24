Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development?
    provider :developer,
      fields: [:forum_member_id, :email],
      uid_field: :forum_member_id
  end

  provider :discourse,
    # sso_url: URI.join(Rails.configuration.endpoints[:discourse], "/session/sso_provider"),
    sso_url: "https://forums.29th.local/session/sso_provider",
    sso_secret: ENV.fetch("DISCOURSE_SSO_SECRET")
end

OmniAuth.config.logger = Rails.logger
