class PassesController < ApplicationController
  def index
    authorize Pass
    @query = Pass.ransack(params[:q])
    @passes = @query.result(distinct: true)
      .includes(user: :rank)
      .page(params[:page])
      .order(add_date: :desc)
    @users = users_for_select
  end

  def show
    @pass = Pass.find(params[:id])
    authorize @pass
  end

  private

  def users_for_select
    User.active.includes(:rank).order(:last_name)
  end
end
