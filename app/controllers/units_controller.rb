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
      :accepted_recruited_enlistments,
      user_awards: :award,
      non_training_assignments: :unit
    )

    @users_with_missing_awards = {}
    users.each do |user|
      missing_awards = MissingAwardCalculator.call(user)

      # Only include users with missing awards
      if missing_awards[:aocc] > 0 || missing_awards[:ww1v] > 0 ||
          missing_awards[:cab1] > 0 || missing_awards[:cab2] > 0 ||
          missing_awards[:cab3] > 0 || missing_awards[:cab4] > 0
        @users_with_missing_awards[user] = {
          service_duration: user.service_duration,
          missing_awards:
        }
      end
    end
  end

  def stats
    @wide = true

    # Get units in hierarchical order
    units = @unit.subtree.active
    unit_tree = units.arrange(order: :order)

    # Flatten the tree while preserving hierarchical order
    @units = flatten_arranged_units(unit_tree)

    # Get assignments with proper ordering and all needed associations for stats
    @assignments_by_unit = Assignment.active
      .includes(user: [:rank, :latest_non_honorable_discharge, :assignments])
      .includes(:position)
      .where(unit_id: units.ids)
      .order("positions.order DESC, ranks.order DESC")
      .group_by(&:unit_id)
    @users_by_unit = @assignments_by_unit.transform_values { |assignments| assignments.map(&:user) }

    # Get all user IDs for preloading attendance stats
    users = @users_by_unit.values.flatten.uniq
    user_ids = users.map(&:id)

    # Preload attendance stats for all users at once
    @attendance_stats_by_user_id = AttendanceStats.for_users(user_ids)
      .index_by(&:member_id)

    @standard_progress_by_user = StandardProgressCalculator.call(users, @unit.game)
  end

  def discharges
    @discharges = Discharge.for_unit(@unit.subtree) # include inactive units
      .includes(user: :rank)
      .desc
      .page(params[:page])
  end

  def recruits
    @wide = true

    # Set up ransack query for filtering
    @query = Enlistment
      .accepted
      .with_recruit_result
      .includes(:unit, user: :rank, recruiter_user: :rank)
      .where(recruiter_user: @unit.subtree_users.active)
      .ransack(params[:q])

    @recruited_enlistments = @query.result(distinct: true)
      .order(date: :desc)
      .page(params[:page])

    # Get users for the filter dropdowns
    @recruiters = @unit.subtree_users.active.includes(:rank).order("rank.order DESC", "last_name")
  end

  private

  # Helper method to flatten an arranged tree of units while preserving hierarchical order
  def flatten_arranged_units(arranged_units)
    arranged_units.flat_map do |unit, children|
      [unit, *flatten_arranged_units(children)]
    end
  end

  def find_and_authorize_unit
    @unit = Unit.friendly.find(params[:unit_id] || params[:id])
    authorize @unit
  end
end
