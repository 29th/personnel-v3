class HomeController < ApplicationController
  def index
    skip_authorization
  end
end
