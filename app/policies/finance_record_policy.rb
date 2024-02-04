class FinanceRecordPolicy < Manage::FinanceRecordPolicy
  def index?
    user&.member?
  end

  def show?
    index?
  end
end
