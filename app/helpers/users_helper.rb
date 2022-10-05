module UsersHelper
  def build_steam_link(steam_id)
    "https://steamcommunity.com/profiles/#{steam_id}"
  end

  def discourse_user_url(user)
    base_url = Rails.configuration.endpoints[:discourse][:base_url][:external]
    "#{base_url}/user-by-id/#{user.forum_member_id}/summary"
  end

  def v2_user_url(user)
    base_url = Rails.configuration.endpoints[:personnel_v2_app][:base_url][:external]
    "#{base_url}/#members/#{user.id}"
  end

  def format_donation_balance(balance)
    number_to_currency(balance, precision: 0, unit: "$")
  end

  def link_to_forum_topic(label, object)
    topic_id = object.topic_id
    case object.forum_id
    when "discourse"
      url = discourse_url(topic: topic_id)
    when "vanilla"
      url = vanilla_url(topic: topic_id)
    when "smf"
      url = smf_url(topic: topic_id)
    end

    if url
      link_to label, url
    else
      label
    end
  end
end
