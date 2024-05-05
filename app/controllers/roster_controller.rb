class RosterController < ApplicationController
  def index
    units = Unit.find_root.subtree.active
    @unit_tree = units.arrange(order: :order)
    @assignments = Assignment.active.roster(units.ids)

    @slim = params.key?(:slim)
  end

  def squad_xml
    @users = User.active
      .includes(:rank, active_assignments: [:unit, :position])
      .merge(Assignment.ordered)
    render "squad", formats: :xml
  end
end
