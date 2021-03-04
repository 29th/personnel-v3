class HomeController < ApplicationController
  layout 'about', except: :landing

  def landing
  end

  def about
  end

  def awards
    @awards = Award.active.notapplicable
  end

  def realism
  end

  def ranks
    @ranks = Rank.all.order(order: :desc)
  end

  def enlist
  end

  def servers
    order = %w[Battalion Company Platoon Squad Public Euro]
    @servers_by_game = Server.active
                             .sort_by { |server| order.index(server.name.split.first) || 99 }
                             .group_by { |server| Server.games[server.game] }
  end

  def historical
  end

  def server_rules
  end

  def donate
  end

  def faq
  end

  def record
  end

  def our_history
  end

  def contact
  end
end
