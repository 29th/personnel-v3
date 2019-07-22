class AssignmentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user and (user.has_permission_on_user?('assignment_add', record) or user.has_permission?('assignment_add_any'))
  end

  def update?
    user and user.has_permission_on_user?('assignment_add', record)
  end

  def destroy?
    user and user.has_permission_on_user?('assignment_delete', record)
  end
end
