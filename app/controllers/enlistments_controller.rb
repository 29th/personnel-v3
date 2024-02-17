class EnlistmentsController < ApplicationController
  def new
    authorize Enlistment
    @enlistment = Enlistment.new
  end
end
