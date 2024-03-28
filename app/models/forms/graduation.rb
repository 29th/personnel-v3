class Forms::Graduation
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :training_platoon
  attr_reader :award_ids
  attribute :rank_id, :integer
  attribute :position_id, :integer
  attribute :topic_id, :integer

  validates :training_platoon, presence: true
  validates :award_ids, presence: true
  validates :rank_id, presence: true
  validates :position_id, presence: true
  validates :topic_id, presence: true

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

    relevant_assignments = assignments.filter { |assignment| assignment.unit_id.present? }

    # Triggering n+1 because verify_eligibility! access user's other assignments
    relevant_assignments.each { |assignment| verify_eligibility!(assignment.user) }

    ActiveRecord::Base.transaction do
      relevant_assignments.each(&method(:process_graduation_assignment!))

      training_platoon.end_assignments
      training_platoon.update!(active: false)
    end

    relevant_assignments.each { |assignment| queue_background_jobs(assignment.user) }
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

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
