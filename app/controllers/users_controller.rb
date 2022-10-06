class UsersController < ApplicationController
  layout "user"

  def show
    @user = User.friendly.find(params[:id])
    @donated = FinanceRecord.user_donated(@user)
    authorize @user
  end

  def service_record
    @user = User.friendly.find(params[:user_id])
    authorize @user

    user_awards = @user.user_awards.order(date: :desc)
    promotions = @user.promotions.order(date: :desc)
    assignments = @user.assignments.select("*, start_date AS date").order(start_date: :desc)
    demerits = @user.demerits.order(date: :desc)
    discharges = @user.discharges.order(date: :desc)
    enlistments = @user.enlistments.order(date: :desc)

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
