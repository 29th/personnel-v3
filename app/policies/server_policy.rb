class ServerPolicy < Manage::ServerPolicy
  def index?
    true
  end

  def show?
    true
  end
end
