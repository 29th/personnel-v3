module UsersHelper
  def build_steam_link(steam_id)
    "https://steamcommunity.com/profiles/#{steam_id}"
  end

  def discourse_user_url(user)
    base_url = Settings.discourse.base_url.external
    "#{base_url}/user-by-id/#{user.forum_member_id}/summary"
  end

  def coat_url(user)
    if user.member? || user.honorably_discharged?
      if user.service_coat.present?
        user.service_coat_url
      end
    end
  end

  def format_donation_balance(balance)
    number_to_currency(balance, precision: 0, unit: "$")
  end

  def render_service_record_partial(item)
    render partial: item.class.name.underscore, object: item
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

    if url && valid_topic_id(topic_id)
      link_to label, url
    else
      label
    end
  end

  def format_service_duration(duration)
    relevant_units = [:years, :months, :weeks, :days].freeze

    duration.parts
      .slice(*relevant_units)
      .sort_by { |unit, _| relevant_units.index(unit) }
      .map { |unit, val| pluralize(val, unit.to_s.singularize) }
      .to_sentence
  end

  private

  # If no announcement was made, topic_id is often set to 0
  # or "0" in cases where the column is a string.
  def valid_topic_id(topic_id)
    topic_id.present? && topic_id.to_s != "0"
  end
end
