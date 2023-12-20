class RosterController < ApplicationController
  def index
    units = Unit.find_root
      .subtree
      .active

    @unit_tree = units.arrange(order: :order)

    @assignments = Assignment.active
      .includes(user: :rank)
      .includes(:position)
      .where(unit_id: units.ids)
      .order("positions.order DESC, ranks.order DESC")
      .group_by(&:unit_id)

    @slim = params.key?(:slim)
    @show_discourse_status = params.key?(:discourse)
  end

  def search
    authorize User
    @users = User
      .ransack(params[:q])
      .result(dinstinct: true)
      .includes(:rank, :discharges, active_assignments: :unit)
      .order(last_name: :desc)
  end
end
