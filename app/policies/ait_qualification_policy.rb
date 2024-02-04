class AITQualificationPolicy < Manage::AITQualificationPolicy
  def index?
    user&.member?
  end

  def show?
    index?
  end
end
