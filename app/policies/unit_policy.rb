class UnitPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    false
  end

  def update?
    user and user.has_permission_on_unit?('edit_unit', record)
  end

  def destroy?
    false
  end
end
