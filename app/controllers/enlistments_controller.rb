class EnlistmentsController < ApplicationController
  def show
    @enlistment = Enlistment.find(params[:id])
    authorize @enlistment
  end

  def new
    authorize Enlistment
    @enlistment = Enlistment.new
  end

  def create
    @enlistment = Enlistment.new(enlistment_params)
    @enlistment.date = Date.today

    if current_user.is_a?(UnregisteredUser)
      @enlistment.user = current_user.to_normal_user(user_params)
      is_new_user = true
    else
      @enlistment.user = current_user
    end

    authorize @enlistment

    if @enlistment.save
      sign_in_as @enlistment.user if is_new_user

      CreateEnlistmentForumTopicJob.perform_now(@enlistment)

      redirect_to @enlistment, notice: "Enlistment was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def sign_in_as(user)
    reset_session
    session[:user_id] = user.id
  end

  def enlistment_params
    params.require(:enlistment).permit(
      :first_name,
      :middle_name,
      :last_name,
      :age,
      :country_id,
      :timezone,
      :game,
      :ingame_name,
      :steam_id,
      :recruiter,
      :experience,
      :comments,
      previous_units_attributes: [
        :unit, :game, :name, :rank, :reason, :_destroy
      ]
    )
  end

  def user_params
    params.require(:enlistment).permit(
      :first_name,
      :middle_name,
      :last_name,
      :country_id,
      :steam_id
    )
  end
end
