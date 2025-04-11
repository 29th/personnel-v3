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
    # get relevant awards
    aocc = Award.find_by(code: "aocc")
    ww1v = Award.find_by(code: "ww1v")

    @users_with_missing_awards = {}

    # Get all active users in the unit's subtree with preloaded associations to avoid N+1 queries
    users = @unit.subtree_users.active.includes(
      :rank,
      :latest_non_honorable_discharge,
      :user_awards,
      non_training_assignments: :unit
    )

    users.each do |user|
      # Use the optimized service_duration method that avoids N+1 queries
      service_duration = user.service_duration

      # Calculate how many awards the user should have based on service duration
      months_of_service = (service_duration.to_i / 1.month).floor
      years_of_service = (service_duration.to_i / 1.year).floor

      # For every 6 months of service, a user should be awarded an Army of Occupation Medal (aocc)
      expected_aocc_count = (months_of_service / 6).floor

      # For every 2 years of service, a user should be awarded a World War I Victory Medal (ww1v)
      expected_ww1v_count = (years_of_service / 2).floor

      # Count how many of each award the user already has
      # Using preloaded user_awards and filtering in memory to avoid N+1 queries
      actual_aocc_count = user.user_awards.count { |ua| ua.award_id == aocc.id }
      actual_ww1v_count = user.user_awards.count { |ua| ua.award_id == ww1v.id }

      # Calculate missing awards
      missing_aocc = expected_aocc_count - actual_aocc_count
      missing_ww1v = expected_ww1v_count - actual_ww1v_count

      # Only include users with missing awards
      if missing_aocc > 0 || missing_ww1v > 0
        @users_with_missing_awards[user] = {
          service_duration: service_duration,
          missing_aocc: (missing_aocc > 0) ? missing_aocc : 0,
          missing_ww1v: (missing_ww1v > 0) ? missing_ww1v : 0
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
