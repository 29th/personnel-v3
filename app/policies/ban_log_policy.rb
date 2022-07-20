class BanLogPolicy < ApplicationPolicy
  def index?
    user&.member?
  end

  def show?
    index?
  end

  def new?
    user&.has_permission?("banlog_edit_any") ||
      user&.has_permission?("admin")
  end

  def create?
    new?
  end

  def update?
    new?
  end

  def destroy?
    user&.has_permission?("admin")
  end
end
