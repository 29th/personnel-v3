class AITQualificationPolicy < ApplicationPolicy
  def index?
    user&.member?
  end

  def show?
    index?
  end

  def new?
    user&.has_permission?("qualification_add") ||
      user&.has_permission?("qualification_add_any") ||
      user&.has_permission?("admin")
  end

  def create?
    (record.user && user&.has_permission_on_user?("qualification_add", record.user)) ||
      user&.has_permission?("qualification_add_any") ||
      user&.has_permission?("admin")
  end

  def update?
    create?
  end

  def destroy?
    (record.user && user&.has_permission_on_user?("qualification_delete", record.user)) ||
      user&.has_permission?("qualification_delete_any") ||
      user&.has_permission?("admin")
  end
end
