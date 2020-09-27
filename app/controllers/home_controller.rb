class HomeController < ApplicationController
  def index
    skip_authorization

    @splashes = Rails.configuration.homepage.splashes
  end
end
