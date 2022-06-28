class EventsController < ApplicationController
  def index
    authorize Event

    date_param = params.fetch(:start_date, Date.today).to_date
    start_date = date_param.beginning_of_month
    end_date = date_param.end_of_month

    @query = Event.ransack(params[:q])
    @events = @query.result(distinct: true)
      .includes(:unit)
      .where("date(datetime) >= ? AND date(datetime) <= ?",
        start_date, end_date)
      .order(:datetime)

    @view_by = params.fetch(:view_by, "week")
  end

  def show
    @event = Event.find(params[:id])
    authorize @event
  end
end
