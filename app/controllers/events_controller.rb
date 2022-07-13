class EventsController < ApplicationController
  def index
    authorize Event

    date_param = params.fetch(:start_date, Date.today).to_date
    start_date = date_param.beginning_of_month.beginning_of_week
    end_date = date_param.end_of_month.end_of_week

    @events = Event.where(datetime: start_date..end_date)
      .includes(:unit)
      .order(:datetime)

    @view_by = params.fetch(:view_by, "week")
  end

  def show
    @event = Event.find(params[:id])
    @attendance_records = @event.attendance_records
      .includes(:event, user: :extended_loas)
    authorize @event
  end

  def edit_aar
    @event = Event.find(params[:id])
    @attended_user_ids = @event.attendance_records.where(attended: true).pluck(:member_id)
    @expected_users = @event.expected_users.order("ranks.order DESC", "last_name")
    authorize @event, :aar?
  end

  def update_aar
    @event = Event.find(params[:id])
    authorize @event, :aar?

    @event.report = params[:event][:report]
    @event.reporter = current_user

    attended_ids = params[:event][:user_ids].reject(&:empty?).map(&:to_i)
    attendance_result = @event.update_attendance(attended_ids)
    @event.excuse_users_on_extended_loa

    if attendance_result && @event.save
      redirect_to @event, notice: "AAR was successfully updated."
    else
      @attended_user_ids = @event.attendance_records.where(attended: true).pluck(:member_id)
      @expected_users = @event.expected_users.order("ranks.order DESC", "last_name")
      render :edit_aar
    end
  end

  def loa
    @event = Event.find(params[:id])
    authorize @event

    if @event.posted_loa?(current_user)
      if @event.cancel_loa(current_user)
        redirect_to @event, notice: "LOA was successfully cancelled."
      end
    elsif @event.post_loa(current_user)
      redirect_to @event, notice: "LOA was successfully posted."
    end
  end
end
