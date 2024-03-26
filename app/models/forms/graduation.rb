class Forms::Graduation
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :training_platoon
  # attr_accessor :cadets
  attr_reader :award_ids
  attribute :rank_id, :integer
  attribute :position_id, :integer
  attribute :topic_id, :integer

  validates :training_platoon, presence: true
  validates :award_ids, presence: true
  validates :rank_id, presence: true
  validates :position_id, presence: true
  # validates :cadets, presence: true
  validates :topic_id, presence: true
  validate :assignments_have_unit_ids

  def assignments
    @assignments ||= training_platoon.enlistments
      .accepted
      .includes(user: :rank)
      .map do |enlistment|
      Assignment.new(user: enlistment.user)
    end
  end

  def assignments_attributes=(attributes)
    @assignments = attributes.values.map { |attrs| Assignment.new(attrs) }
  end

  def award_ids=(award_ids)
    @award_ids = award_ids.filter(&:present?)
  end

  def save
    return false unless valid?

    # Triggering n+1 because verify_eligibility! access user's other assignments
    assignments.each { |assignment| verify_eligibility!(assignment.user) }

    ActiveRecord::Base.transaction do
      assignments.each(&method(:process_graduation_assignment!))

      training_platoon.end_assignments
      training_platoon.update!(active: false)
    end

    assignments.each { |assignment| queue_background_jobs(assignment.user) }
  rescue ActiveRecord::RecordInvalid => exc
    false
  end

  private

  def assignments_have_unit_ids
    unless assignments.all? { |assignment| assignment.unit_id.present? }
      errors.add(:assignments, "unit is required")
    end
  end

  def verify_eligibility!(user)
    if user.member? || !user.assigned_to_unit?(training_platoon) ||
        !training_platoon.enlistments.accepted.exists?(user: user)
      raise IneligibleCadet.new(user: user)
    end
  end

  def process_graduation_assignment!(assignment)
    user = assignment.user

    assignment.assign_attributes(position_id: position_id, start_date: Date.current)
    user.assignments << assignment

    user.promotions.build(new_rank_id: rank_id, old_rank_id: user.rank.id,
      date: Date.current, forum_id: :discourse, topic_id: topic_id)
    user.rank_id = rank_id

    award_ids.each do |award_id|
      user.user_awards.build(award_id: award_id, date: Date.current,
        forum_id: :discourse, topic_id: topic_id)
    end

    user.save!
  end

  def queue_background_jobs(user)
    user.delay.update_forum_display_name
    user.delay.update_forum_roles
    user.delay.update_coat
  end

  class IneligibleCadet < StandardError
    attr_reader :user

    def initialize(message = nil, user: nil)
      @user = user
      message ||= "Cadet is ineligible for graduation: #{user}"
      super(message)
    end
  end
end
