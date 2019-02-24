class RankPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user and user.has_permission?('admin')
  end

  def update?
    user and user.has_permission?('admin')
  end

  def destroy?
    user and user.has_permission?('admin')
  end
end
