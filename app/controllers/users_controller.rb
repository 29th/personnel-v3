class UsersController < ApplicationController
  before_action :find_and_authorize_user, :find_assignments
  layout "user"

  def show
    @donated = FinanceRecord.user_donated(@user)
  end

  def service_record
    user_awards = @user.user_awards.includes(:award).order(date: :desc)
    promotions = @user.promotions.includes(:new_rank, :old_rank).order(date: :desc)
    assignments = @user.assignments.includes(:unit, :position).select("*, start_date AS date").order(start_date: :desc)
    demerits = @user.demerits.order(date: :desc)
    discharges = @user.discharges.order(date: :desc)
    enlistments = @user.enlistments.includes(:unit).order(date: :desc)

    @items_by_year = (
      user_awards +
      promotions +
      assignments +
      demerits +
      discharges +
      enlistments)
      .sort_by(&:date)
      .reverse
      .group_by { |item| item.date.year }
  end

  def attendance
    @attendance_records = @user.attendance_records
      .includes(event: :unit)
      .order("event.starts_at DESC")
      .page(params[:page])

    @attendance_stats = @user.attendance_stats
  end

  private

  def find_and_authorize_user
    @user = User.friendly.find(params[:user_id] || params[:id])
    authorize @user
  end

  def find_assignments
    @active_assignments = @user.assignments.active.includes(:unit, :position)
  end
end
