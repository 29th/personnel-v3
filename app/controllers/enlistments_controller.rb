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
    @enlistment.user = current_user

    # Don't allow existing users to update their name etc.
    @enlistment.user.assign_attributes(user_params) unless @enlistment.user.persisted?

    authorize @enlistment

    if @enlistment.save
      ensure_signed_in_as @enlistment.user

      CreateEnlistmentForumTopicJob.perform_now(@enlistment)

      redirect_to @enlistment, notice: "Enlistment was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def ensure_signed_in_as(user)
    unless session[:user_id] == user.id
      reset_session
      session[:user_id] = user.id
    end
  end

  def enlistment_params
    params.require(:enlistment).permit(
      :age,
      :timezone,
      :game,
      :ingame_name,
      :recruiter,
      :experience,
      :comments,
      previous_units_attributes: [
        :unit, :game, :name, :rank, :reason, :_destroy
      ]
    )
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :middle_name,
      :last_name,
      :country_id,
      :steam_id
    )
  end
end
