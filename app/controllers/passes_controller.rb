class PassesController < ApplicationController
  def index
    authorize Pass
    @passes = Pass.includes(user: :rank)
                  .page(params[:page])
                  .order(add_date: :desc)
  end

  def show
    @pass = Pass.find(params[:id])
    authorize @pass
  end

  def new
    authorize Pass
    @pass = Pass.new
    @users = users_for_select
  end

  def create
    bulk_member_ids = pass_params[:bulk_member_ids].select(&:present?)
                                                   .first(5) # Restrict over-loading

    passes = bulk_member_ids.map do |member_id|
      pass = Pass.new(pass_params)
      pass.member_id = member_id
      pass.author = current_user
      pass
    end

    passes.each do |pass|
      authorize pass
    end

    passes.each do |pass|
      @pass = pass # Before 'next' so redirect works
      next if pass.save

      @pass.bulk_member_ids = bulk_member_ids
      @users = users_for_select
      render :new
      return
    end

    if bulk_member_ids.length == 1
      redirect_to @pass, notice: 'Pass was successfully created.'
    else
      redirect_to passes_path, notice: 'Passes were successfully created.'
    end
  end

  def edit
    @pass = Pass.find(params[:id])
    @users = users_for_select
    authorize @pass
  end

  def update
    @pass = Pass.find(params[:id])
    authorize @pass
    if @pass.update(pass_params)
      redirect_to @pass, notice: 'Pass was successfully updated.'
    else
      @users = users_for_select
      render :edit
    end
  end

  def destroy
    @pass = Pass.find(params[:id])
    authorize @pass
    @pass.destroy
    redirect_to passes_path, notice: 'Pass was successfully destroyed.'
  end

  private

  def users_for_select
    User.active.includes(:rank).order(:last_name)
  end

  def pass_params
    params.require(:pass).permit(:start_date, :end_date,
                                 :type, :reason, :member_id,
                                 { bulk_member_ids: [] })
  end
end
