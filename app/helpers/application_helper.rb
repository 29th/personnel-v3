module ApplicationHelper
  def homepage_config
    Rails.configuration.homepage
  end

  def discourse_url
    Rails.configuration.endpoints[:discourse][:base_url][:external]
  end

  def personnel_v2_app_url
    Rails.configuration.endpoints[:personnel_v2_app][:base_url][:external]
  end
end
