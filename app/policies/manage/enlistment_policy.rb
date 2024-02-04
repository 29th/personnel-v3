class Manage::EnlistmentPolicy < ApplicationPolicy
  def index?
    user&.has_permission?("enlistment_edit_any") ||
      user&.has_permission?("enlistment_process_any") ||
      user&.has_permission?("enlistment_assign_any") ||
      user&.has_permission?("admin")
  end

  def show?
    index?
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
    (record.date > 3.months.ago && user&.has_permission?("enlistment_edit_any")) ||
      user&.has_permission?("admin")
  end

  def process_enlistment?
    (record.date > 3.months.ago && user&.has_permission?("enlistment_process_any")) ||
      user&.has_permission?("admin")
  end

  def destroy?
    user&.has_permission?("admin")
  end

  def transfer?
    user&.has_permission?("admin")
  end

  def assign_liaison?
    user&.has_permission?("enlistment_assign_any") ||
      user&.has_permission?("admin")
  end
end
