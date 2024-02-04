class Manage::PassPolicy < ApplicationPolicy
  def index?
    new?
  end

  def show?
    new?
  end

  def new?
    user && (user.has_permission?("pass_edit") ||
             user.has_permission?("pass_edit_any") ||
             user.has_permission?("admin"))
  end

  def create?
    user && ((record.user && user.has_permission_on_user?("pass_edit", record.user)) ||
             user.has_permission?("pass_edit_any") ||
             user.has_permission?("admin"))
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
