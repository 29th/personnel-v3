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
  end

  def show
    @event = Event.find(params[:id])
    authorize @event
  end

  def new
    authorize Event
    @event = Event.new
    @units = units_for_select
  end

  def create
    @event = Event.new(event_params)
    authorize @event

    if @event.save
      redirect_to @event, notice: "Event was succesfully created."
    else
      @units = units_for_select
      render :new
    end
  end

  def edit
    @event = Event.find(params[:id])
    authorize @event
    @units = units_for_select
  end

  def update
    @event = Event.find(params[:id])
    authorize @event

    if @event.update(event_params)
      redirect_to @event, notice: "Event was successfully updated."
    else
      @units = units_for_select
      render :edit
    end
  end

  def destroy
    @event = Event.find(params[:id])
    authorize @event

    @event.destroy
    redirect_to events_path, notice: "Event was successfully destroyed."
  end

  private

  def units_for_select
    Unit.active
  end

  def event_params
    params.require(:event).permit(:datetime, :unit_id, :type, :mandatory)
  end
end
