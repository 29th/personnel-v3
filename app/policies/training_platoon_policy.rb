class TrainingPlatoonPolicy < ApplicationPolicy
  def index?
    user&.has_permission?("admin")
  end

  def show?
    user&.has_permission?("admin")
  end

  def graduate?
    user&.has_permission?("admin")
  end
end
