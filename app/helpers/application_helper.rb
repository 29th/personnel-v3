module ApplicationHelper
  def homepage_config
    Rails.configuration.homepage
  end

  # Returns true if an asset exists in the Asset Pipeline, false if not.
  def asset_exists?(path)
    begin
      pathname = Rails.application.assets.resolve(path)
      return !!pathname # double-bang turns String into boolean
    rescue Sprockets::FileNotFound
      return false
    end
  end
end
