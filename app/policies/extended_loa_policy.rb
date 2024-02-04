class ExtendedLOAPolicy < Manage::ExtendedLOAPolicy
  def index?
    user&.member?
  end

  def show?
    index?
  end
end
