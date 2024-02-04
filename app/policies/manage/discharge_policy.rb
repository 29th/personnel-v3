class Manage::DischargePolicy < ApplicationPolicy
  def index?
    new?
  end

  def show?
    new?
  end

  def new?
    user&.has_permission?("discharge_add") ||
      user&.has_permission?("discharge_add_any")
  end

  def create?
    user&.has_permission_on_user?("discharge_add", record.user) ||
      user&.has_permission?("discharge_add_any") ||
      user&.has_permission?("admin")
  end

  def update?
    user&.has_permission_on_user?("discharge_add", record.user) ||
      user&.has_permission?("discharge_add_any") ||
      user&.has_permission?("admin")
  end

  def destroy?
    user&.has_permission?("admin")
  end
end
