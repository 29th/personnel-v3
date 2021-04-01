class UserPolicy < ApplicationPolicy
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
    (record && user&.has_permission_on_user?("profile_edit", record)) ||
      user&.has_permission?("profile_edit_any") ||
      user&.has_permission?("admin")
  end

  def destroy?
    user&.has_permission?("admin")
  end

  def update_forum_roles?
    user&.has_permission_on_user?("assignment_edit", record) ||
      user&.has_permission?("assignment_edit_any") ||
      user&.has_permission?("admin")
  end
end
