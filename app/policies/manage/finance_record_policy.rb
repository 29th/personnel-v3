class Manage::FinanceRecordPolicy < ApplicationPolicy
  def index?
    new?
  end

  def show?
    new?
  end

  def new?
    user&.has_permission?("finance_add") ||
      user&.has_permission?("admin")
  end

  def create?
    new?
  end

  def update?
    new?
  end

  def destroy?
    new?
  end
end
