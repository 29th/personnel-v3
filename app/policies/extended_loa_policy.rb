class ExtendedLOAPolicy < ApplicationPolicy
  def index?
    user&.member?
  end

  def show?
    index?
  end

  def new?
    user&.has_permission?("eloa_add") ||
      user&.has_permission?("eloa_add_any") ||
      user&.has_permission?("admin")
  end

  def create?
    (record.user && user&.has_permission_on_user?("eloa_add", record.user)) ||
      user&.has_permission?("eloa_add_any") ||
      user&.has_permission?("admin")
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
