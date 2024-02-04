class UserPolicy < Manage::UserPolicy
  def index?
    true
  end

  def show?
    true
  end

  def search?
    user&.member?
  end

  def service_record?
    show?
  end

  def attendance?
    user&.member?
  end

  def qualifications?
    AITQualificationPolicy.new(user, AITQualification).index?
  end

  def recruits?
    show?
  end

  def reprimands?
    DemeritPolicy.new(user, Demerit).index?
  end

  def extended_loas?
    ExtendedLOAPolicy.new(user, ExtendedLOA).index?
  end
end
