class DemeritPolicy < Manage::DemeritPolicy
  def index?
    user&.member?
  end

  def show?
    index?
  end
end
