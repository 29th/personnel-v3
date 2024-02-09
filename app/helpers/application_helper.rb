module ApplicationHelper
  def homepage_config
    Rails.configuration.homepage
  end

  def discourse_url(user: nil, topic: nil)
    url = Settings.discourse.base_url.external
    if user.present?
      case user
      when User
        user_id = user.forum_member_id
        url += "/user-by-id/#{user_id}/summary"
      when Numeric
        user_id = user.to_s
        url += "/user-by-id/#{user_id}/summary"
      when String
        username = user
        url += "/u/#{username}/summary"
      end
    elsif topic.present?
      url += "/t/#{topic}"
    end
    url
  end

  def vanilla_url(user: nil, topic: nil)
    url = Settings.vanilla.base_url.external
    if user.present?
      case user
      when User
        user_id = user.vanilla_forum_member_id
        name = user.last_name
      when Numeric
        user_id = user
        name = "profile" # vanilla just needs any string as a suffix
      end
      url += "/profile/#{user_id}/#{name}"
    elsif topic.present?
      url += "/discussion/#{topic}"
    end
    url
  end

  def smf_url(topic: nil)
    url = Settings.smf.base_url.external
    if topic.present?
      url += "/?topic=#{topic}"
    end
    url
  end

  def personnel_v2_app_url(user: nil, unit: nil, suffix: nil)
    base_url = Settings.personnel_v2_app.base_url.external
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
