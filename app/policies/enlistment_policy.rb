class EnlistmentPolicy < ApplicationPolicy
  def index?
    user&.member?
  end

  def show?
    user&.member? || (user && record.user == user)
  end

  # Show linked users, IPs, ban logs, etc.
  def analyze?
    update?
  end

  def new?
    false
  end

  def create?
    false
  end

  def update?
    user&.has_permission?("enlistment_edit_any") ||
      user&.has_permission?("admin")
  end

  def process_enlistment?
    user&.has_permission?("enlistment_process_any") ||
      user&.has_permission?("admin")
  end

  def destroy?
    false
  end

  def transfer?
    user&.has_permission?("admin")
  end
end
