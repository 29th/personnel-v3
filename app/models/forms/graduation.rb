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

  # Preload the users and units to avoid n+1 queries later
  def assignments_attributes=(attributes)
    user_ids = attributes.values.pluck("member_id")
    users_by_id = User.where(id: user_ids).includes(:rank).index_by(&:id)

    unit_ids = attributes.values.pluck("unit_id")
    units_by_id = Unit.active.where(id: unit_ids).index_by(&:id)

    @assignments = attributes.values.map do |attrs|
      user_id = attrs["member_id"]&.to_i
      user = users_by_id[user_id]

      unit_id = attrs["unit_id"]&.to_i
      unit = units_by_id[unit_id]

      Assignment.new(user:, unit:)
    end
  end

  def award_ids=(award_ids)
    @award_ids = award_ids.filter(&:present?)
  end

  def awards
    @awards ||= Award.where(id: award_ids)
  end

  def position
    @position ||= Position.find(position_id)
  end

  def rank
    @rank ||= Rank.find(rank_id)
  end

  def save
    return false unless valid?

    relevant_assignments = assignments.filter { |assignment| assignment.unit.present? }

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

  # Include user attribute in built records (even though it isn't necessary)
  # to avoid n+1 queries
  def process_graduation_assignment!(assignment)
    user = assignment.user
    date = Date.current

    assignment.assign_attributes(position: position, start_date: date)
    user.assignments << assignment

    user.promotions.build(new_rank: rank, old_rank: user.rank, date:, topic_id:,
      user:, forum_id: :discourse)
    user.rank = rank

    awards.each do |award|
      user.user_awards.build(award:, date:, topic_id:, user:, forum_id: :discourse)
    end

    user.save!
  end

  def queue_background_jobs(user)
    UpdateDiscourseDisplayNameJob.perform_later(user)
    UpdateDiscourseRolesJob.perform_later(user)
    GenerateServiceCoatJob.perform_later(user)
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
