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
      .event_on_or_after(90.days.ago)
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

  def missing_awards
    # Get all active users in the unit's subtree with preloaded associations to avoid N+1 queries
    users = @unit.subtree_users.active.includes(
      :rank,
      :latest_non_honorable_discharge,
      user_awards: :award,
      non_training_assignments: :unit
    )

    @users_with_missing_awards = {}
    users.each do |user|
      missing_awards = MissingAwardCalculator.call(user)

      # Only include users with missing awards
      if missing_awards[:aocc] > 0 || missing_awards[:ww1v] > 0
        @users_with_missing_awards[user] = {
          service_duration: user.service_duration,
          missing_awards:
        }
      end
    end
  end

  private

  def find_and_authorize_unit
    @unit = Unit.friendly.find(params[:unit_id] || params[:id])
    authorize @unit
  end
end
