class BanLogPolicy < Manage::BanLogPolicy
  def index?
    user&.member?
  end

  def show?
    index?
  end
end
