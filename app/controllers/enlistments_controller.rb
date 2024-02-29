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
      @enlistment.user.forum_member_id = current_user.forum_member_id
      @enlistment.user.email = current_user.forum_member_email
      @enlistment.user.time_zone = current_user.time_zone
      @enlistment.user.rank = Rank.recruit
      is_new_user = true
    else
      @enlistment.user = current_user
    end

    # Copy user attributes to legacy enlistment fields
    @enlistment.last_name = @enlistment.user.last_name
    @enlistment.middle_name = @enlistment.user.middle_name
    @enlistment.first_name = @enlistment.user.first_name
    @enlistment.steam_id = @enlistment.user.steam_id

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
    attrs = [
      :age,
      :country_id,
      :timezone,
      :game,
      :ingame_name,
      :recruiter,
      :experience,
      :comments,
      previous_units_attributes: [
        :unit, :game, :name, :rank, :reason, :_destroy
      ]
    ]
    user_attrs = [
      user_attributes: [
        :first_name,
        :middle_name,
        :last_name,
        :steam_id
      ]
    ]
    attrs += user_attrs if current_user.is_a?(UnregisteredUser)
    params.require(:enlistment).permit(attrs)
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
