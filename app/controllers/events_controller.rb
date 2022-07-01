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
end
