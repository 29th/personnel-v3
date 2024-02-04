class Manage::SpecialForumRolePolicy < ApplicationPolicy
  def index?
    user&.has_permission?("admin")
  end

  def show?
    user&.has_permission?("admin")
  end

  def create?
    user&.has_permission?("admin")
  end

  def update?
    user&.has_permission?("admin")
  end

  def destroy?
    user&.has_permission?("admin")
  end
end
