require 'jwt'

class JsonWebToken
  SECRET_KEY = ENV['FORUMS_COOKIE_SALT']

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    verify = true
    options = { algorithm: 'HS256' }
    body, header = JWT.decode(token, SECRET_KEY, verify, options)
    HashWithIndifferentAccess.new body
  end
end
