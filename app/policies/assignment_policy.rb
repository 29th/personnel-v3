class AssignmentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def new?
    user && (user.has_permission?('assignment_add') ||
             user.has_permission?('assignment_add_any'))
  end

  def create?
    user && (user.has_permission_on_unit?('assignment_add', record.unit) ||
             user.has_permission?('assignment_add_any'))
  end

  def update?
    user && (user.has_permission_on_unit?('assignment_add', record.unit) ||
             user.has_permission?('assignment_add_any'))
  end

  def destroy?
    # This one is on user
    user && (user.has_permission_on_user?('assignment_delete', record.user) ||
             user.has_permission?('assignment_delete_any'))
  end
end
