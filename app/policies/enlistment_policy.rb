class EnlistmentPolicy < ApplicationPolicy
  def index?
    user&.member?
  end

  def show?
    user&.member? || (user && record.user == user)
  end

  def new?
    user.present?
  end

  def create?
    user.present?
    (record.user && user&.has_permission_on_user?("eloa_add", record.user)) ||
      user&.has_permission?("eloa_add_any") ||
      user&.has_permission?("admin")
  end

  def update?
    user&.has_permission?("enlistment_edit_any") ||
      user&.has_permission?("admin")
  end

  def destroy?
    false
  end
end
