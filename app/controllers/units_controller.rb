class UnitsController < ApplicationController
  before_action :find_and_authorize_unit
  layout "unit"

  def show
    units = @unit.subtree.active
    @unit_tree = units.arrange(order: :order)
    @assignments = Assignment.active.roster(units.ids)
  end

  def attendance
    @events = Event.by_unit(@unit.subtree) # include inactive units
      .past
      .with_stats
      .includes(:unit)
      .order(starts_at: :desc)
      .page(params[:page])

    @attendance_stats = @unit.attendance_stats
  end

  private

  def find_and_authorize_unit
    @unit = Unit.friendly.find(params[:unit_id] || params[:id])
    authorize @unit
  end
end
