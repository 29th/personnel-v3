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
    @event.report_posting_date ||= Time.current
    if @event.changed?
      @event.reporter = current_user
      @event.report_edit_date = Time.current
    end

    attended_ids = params[:event][:user_ids].reject(&:empty?).map(&:to_i)
    expected_ids = @event.expected_users.ids

    attendance_records = expected_ids.collect do |user_id|
      {member_id: user_id, event_id: @event.id,
       attended: attended_ids.include?(user_id)}
    end

    upsert_result = AttendanceRecord.upsert_all(attendance_records)

    if upsert_result && @event.save
      redirect_to @event, notice: "AAR was successfully updated."
    else
      render :edit_aar
    end
  end
end
