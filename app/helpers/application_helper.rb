module ApplicationHelper
  def homepage_config
    Rails.configuration.homepage
  end

  def discourse_url(user: nil)
    base_url = Rails.configuration.endpoints[:discourse][:base_url][:external]
    if user.present?
      case user
      when User
        user_id = user.forum_member_id
      when String
        user_id = user
      end
      base_url += "/user-by-id/#{user_id}/summary"
    end
    base_url
  end

  def personnel_v2_app_url(user: nil, unit: nil, suffix: nil)
    base_url = Rails.configuration.endpoints[:personnel_v2_app][:base_url][:external]
    paths = []

    if user.present?
      case user
      when User
        user_id = user.id
      when Integer, String
        user_id = user
      end
      paths.append("members", user_id)
    elsif unit.present?
      case unit
      when Unit
        unit_id = unit.id
      when Integer, String
        unit_id = unit
      end
      paths.append("units", unit_id)
    end

    paths.append(suffix) if suffix.present?

    if !paths.empty?
      fragment = "#" + paths.join("/")
      base_url = ensure_trailing_slash(base_url)
      base_url + fragment
    else
      base_url
    end
  end

  private

  def ensure_trailing_slash(url)
    url.chomp("/") + "/"
  end
end
