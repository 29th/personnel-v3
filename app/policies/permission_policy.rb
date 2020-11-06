class PermissionPolicy < ApplicationPolicy
  def index?
    user&.has_permission?('admin')
  end

  def show?
    user&.has_permission?('admin')
  end

  def create?
    user and user.has_permission?('admin')
  end

  def update?
    user and user.has_permission?('admin')
  end

  def destroy?
    user and user.has_permission?('admin')
  end
end
