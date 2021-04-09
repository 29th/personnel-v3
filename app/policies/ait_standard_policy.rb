class AITStandardPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user&.has_permission?("admin")
  end

  def update?
    user&.has_permission?("admin")
  end

  def destroy?
    user&.has_permission?("admin")
  end
end
