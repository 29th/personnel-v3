class UsersController < ApplicationController
  layout "user"

  def show
    @user = User.find(params[:id])
    @donated = FinanceRecord.user_donated(@user)
    authorize @user
  end
end
