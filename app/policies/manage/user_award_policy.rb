class Manage::UserAwardPolicy < ApplicationPolicy
  def index?
    new?
  end

  def show?
    new?
  end

  def new?
    user&.has_permission?("awarding_add") ||
      user&.has_permission?("awarding_add_any") ||
      user&.has_permission?("admin")
  end

  def create?
    (record.user && user&.has_permission_on_user?("awarding_add", record.user)) ||
      user&.has_permission?("awarding_add_any") ||
      user&.has_permission?("admin")
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
