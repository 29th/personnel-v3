class HomeController < ApplicationController
  def index
    skip_authorization

    @splashes = Rails.configuration.homepage.splashes
    @games = Rails.configuration.homepage.games
    @playlists = Rails.configuration.homepage.playlists
  end
end
