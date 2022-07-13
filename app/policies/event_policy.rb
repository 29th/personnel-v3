class EventPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user&.member?
  end

  def new?
    user&.has_permission?("event_add") ||
      user&.has_permission?("event_add_any") ||
      user&.has_permission?("admin")
  end

  def create?
    (record.unit && user&.has_permission_on_unit?("event_add", record.unit)) ||
      user&.has_permission?("event_add_any") ||
      user&.has_permission?("admin")
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def aar?
    (record.unit && user&.has_permission_on_unit?("event_aar", record.unit)) ||
      user&.has_permission?("event_aar_any") ||
      user&.has_permission?("admin")
  end

  def loa?
    (user && record.expected_users.include?(user) &&
      record.datetime >= 1.day.ago)
  end
end
