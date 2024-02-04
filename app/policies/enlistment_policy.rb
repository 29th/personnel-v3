class EnlistmentPolicy < Manage::EnlistmentPolicy
  def index?
    user&.member?
  end

  def show?
    user&.member? || (user && record.user == user)
  end
end
