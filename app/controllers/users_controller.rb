class UsersController < ApplicationController
  layout "user"

  def show
    @user = User.friendly.find(params[:id])
    @active_assignments = @user.assignments.active.includes(:unit, :position)
    @donated = FinanceRecord.user_donated(@user)
    authorize @user
  end

  def service_record
    @user = User.friendly.find(params[:user_id])
    @active_assignments = @user.assignments.active.includes(:unit, :position)
    authorize @user

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
end
