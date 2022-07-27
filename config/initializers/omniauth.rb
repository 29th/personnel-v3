Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development?
    provider :developer,
      fields: [:forum_member_id, :email],
      uid_field: :forum_member_id
  end

  discourse_base_url = Rails.configuration.endpoints[:discourse][:base_url][:external]
  provider :discourse,
    sso_url: URI.join(discourse_base_url, "/session/sso_provider"),
    sso_secret: ENV.fetch("DISCOURSE_SSO_SECRET")
end

OmniAuth.config.logger = Rails.logger

OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
