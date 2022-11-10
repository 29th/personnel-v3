class UserPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def service_record?
    show?
  end

  def attendance?
    user&.member?
  end

  def qualifications?
    user&.member?
  end

  def recruits?
    show?
  end

  def reprimands?
    user&.member?
  end

  def create?
    user&.has_permission?("admin")
  end

  def update?
    (record && user&.has_permission_on_user?("profile_edit", record)) ||
      user&.has_permission?("profile_edit_any") ||
      user&.has_permission?("admin")
  end

  def destroy?
    user&.has_permission?("admin")
  end

  def update_forum_roles?
    # Support record being the User class or an instance of a User,
    # which is needed by admin batch action
    (record.is_a?(User) && user&.has_permission_on_user?("assignment_edit", record)) ||
      (record == User && user&.has_permission?("assignment_edit")) ||
      user&.has_permission?("assignment_edit_any") ||
      user&.has_permission?("admin")
  end
end
