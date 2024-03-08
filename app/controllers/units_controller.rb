class UnitsController < ApplicationController
  before_action :find_and_authorize_unit
  layout "unit"

  def show
    units = @unit.subtree.active
    @unit_tree = units.arrange(order: :order)
    @assignments = Assignment.active.roster(units.ids)
  end

  private

  def find_and_authorize_unit
    @unit = Unit.friendly.find(params[:id])
    authorize @unit
  end
end
