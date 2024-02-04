class Manage::ServerPolicy < ApplicationPolicy
  def index?
    create?
  end

  def show?
    create?
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
