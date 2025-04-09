class UnitsController < ApplicationController
  before_action :find_and_authorize_unit
  layout "unit"

  def show
    units = @unit.subtree.active
    @unit_tree = units.arrange(order: :order)
    @assignments = Assignment.active.roster(units.ids)
  end

  def attendance
    @events = Event.for_unit(@unit.subtree) # include inactive units
      .past
      .includes(:unit, :attendance_totals)
      .desc
      .select(:id, :unit_id, :mandatory, :starts_at, :time_zone, :type)
      .page(params[:page])

    @attendance_stats = @unit.attendance_stats
  end

  def awols
    @awols_by_user = AttendanceRecord.by_unit(@unit.subtree)
      .awol
      .active_users
      .includes(user: :rank)
      .order("event.starts_at DESC")
      .group_by(&:user) # {user => [attendance_record, attendance_record, ...]}
      .transform_values do |awols|
        {
          awols:,
          dischargeable_dates: AttendanceRecord.dischargeable_dates(awols)
        }
      end
  end

  private

  def find_and_authorize_unit
    @unit = Unit.friendly.find(params[:unit_id] || params[:id])
    authorize @unit
  end
end
