class EventPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    (record.unit && user&.has_permission_on_unit?('event_view', record.unit)) ||
      user&.has_permission?('event_view_any') ||
      user&.has_permission?('admin')
  end

  def new?
    user&.has_permission?('event_add') ||
    user&.has_permission?('event_add_any') ||
    user&.has_permission?('admin')
  end

  def create?
    (record.unit && user&.has_permission_on_unit?('event_add', record.unit)) ||
      user&.has_permission?('event_add_any') ||
      user&.has_permission?('admin')
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
