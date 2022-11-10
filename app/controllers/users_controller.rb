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

  def qualifications
    @ait_qualifications = @user.ait_qualifications
      .includes(author: :rank)
      .each_with_object({}) do |item, accum|
        accum[item.standard_id] = item
      end

    @ait_standards = AITStandard
      .all
      .each_with_object({}) do |item, accum|
        accum[item.game] ||= KeyedAITStandard.new(item.game)
        accum[item.game].append(item, @ait_qualifications.key?(item.id))
      end

    # Avoid having to check permission for every qualification,
    # as they'd all be the same result
    _key, qualification = @ait_qualifications.first
    @can_create_qualifications = policy(qualification).create? if qualification
    @can_destroy_qualifications = policy(qualification).destroy? if qualification
  end

  def recruits
    @recruited_enlistments = @user.recruited_enlistments
      .accepted
      .includes(:unit, user: :rank)
      .order(date: :desc)
      .page(params[:page])
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
