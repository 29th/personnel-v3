class RosterController < ApplicationController
  def index
    units = Unit.find_root.subtree.active
    @unit_tree = units.arrange(order: :order)
    @assignments = Assignment.active.roster(units.ids)

    @slim = params.key?(:slim)
  end
end
