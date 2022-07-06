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
    authorize @event
  end

  def edit_aar
    @event = Event.find(params[:id])
    authorize @event, :aar?
  end

  def update_aar
    @event = Event.find(params[:id])

    @event.report = params[:event][:report]
    @event.reporter = current_user

    attended_ids = params[:event][:user_ids].reject(&:empty?).map(&:to_i)
    attendance_result = @event.update_attendance(attended_ids)
    @event.excuse_users_on_extended_loa

    if attendance_result && @event.save
      redirect_to @event, notice: "AAR was successfully updated."
    else
      render :edit_aar
    end
  end
end
