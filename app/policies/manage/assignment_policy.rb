class Manage::AssignmentPolicy < ApplicationPolicy
  def index?
    new?
  end

  def show?
    new?
  end

  def new?
    user&.has_permission?("assignment_add") ||
      user&.has_permission?("assignment_add_any")
  end

  def create?
    (user&.has_permission_on_unit?("assignment_add", record.unit) ||
      user&.has_permission?("assignment_add_any") ||
      user&.has_permission?("admin")) &&
      record.user != user
  end

  def update?
    (user&.has_permission_on_unit?("assignment_add", record.unit) ||
      user&.has_permission?("assignment_add_any") ||
      user&.has_permission?("admin")) &&
      record.user != user
  end

  def destroy?
    (user&.has_permission_on_unit?("assignment_delete", record.unit) ||
      user&.has_permission?("assignment_delete_any") ||
      user&.has_permission?("admin")) &&
      record.user != user
  end
end
