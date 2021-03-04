class UnitPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def new?
    user&.has_permission?('unit_add') ||
      user&.has_permission?('admin')
  end

  def create?
    new?
  end

  def update?
    new?
  end

  def destroy?
    user&.has_permission?('admin')
  end
end
