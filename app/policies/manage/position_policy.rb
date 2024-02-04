class Manage::PositionPolicy < ApplicationPolicy
  def index?
    new?
  end

  def show?
    new?
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
