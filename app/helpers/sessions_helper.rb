module SessionsHelper
  def sign_in_path(provider, origin)
    path = "/auth/#{provider}"
    if origin
      "#{path}?origin=#{origin}"
    else
      path
    end
  end
end
