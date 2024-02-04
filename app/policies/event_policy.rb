class EventPolicy < Manage::EventPolicy
  def index?
    user&.member? || user&.honorably_discharged?
  end

  def show?
    user&.member?
  end

  def aar?
    ((record.unit && user&.has_permission_on_unit?("event_aar", record.unit)) ||
      user&.has_permission?("event_aar_any") ||
      user&.has_permission?("admin")) &&
      record.starts_at.beginning_of_day.before?(Time.current)
  end

  def loa?
    (user && record.expected_users.include?(user) &&
      record.starts_at >= 1.day.ago)
  end
end
