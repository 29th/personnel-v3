class PagesController < ApplicationController
  layout 'about'

  def about
  end

  def realism
  end

  def ranks
    @ranks = Rank.all
  end

  def enlist
  end

  def servers
    @servers_by_game = Server.active.group_by(&:game)
  end
end
