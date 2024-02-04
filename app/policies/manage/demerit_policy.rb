class Manage::DemeritPolicy < ApplicationPolicy
  def index?
    new?
  end

  def show?
    new?
  end

  def new?
    user&.has_permission?("demerit_add_any") ||
      user&.has_permission?("admin")
  end

  def create?
    (record.user && user&.has_permission_on_user?("demerit_add", record.user)) ||
      user&.has_permission?("demerit_add_any") ||
      user&.has_permission?("admin")
  end

  def update?
    create?
  end

  def destroy?
    user&.has_permission?("admin")
  end
end
