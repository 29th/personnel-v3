Rails.application.config.session_store :cookie_store,
  key: "_personnel_session",
  expire_after: 30.days,
  secure: Rails.env.production?,
  httponly: true
