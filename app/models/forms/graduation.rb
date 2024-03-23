class Forms::Graduation
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :unit
  attr_accessor :cadets
  attr_accessor :award_ids
  attribute :rank_id, :integer
  attribute :position_id, :integer
  attribute :topic_id, :integer

  validates :unit, presence: true
  validates :award_ids, presence: true
  validates :rank_id, presence: true
  validates :position_id, presence: true
  validates :cadets, presence: true
  validates :topic_id, presence: true

  # "forms_graduation"=>{
  #   "cadets_attributes"=>{
  #     "0"=>{"unit_id"=>"28", "id"=>"92295"},
  #     "1"=>{"unit_id"=>"29", "id"=>"92301"},
  #     "2"=>{"unit_id"=>"1246", "id"=>"92290"}
  #   },
  #   "award_ids"=>["", "27", "109"],
  #   "rank_id"=>"2",
  #   "position_id"=>"1",
  #   "topic_id"=>"123"
  # }
  def cadets_attributes=(attributes)
    attributes_collection = attributes.values.filter { |a| a.key?("id") }
    @assignments = attributes_collection.each_with_object({}) do |a, memo|
      memo[a["id"].to_i] = a["unit_id"].to_i
    end
    user_ids = @assignments.keys
    @cadets = user_ids.empty? ? [] : Cadet.where(id: user_ids)
  end

  def save
    return false unless valid?

    cadets.each(&method(:verify_eligibility!))

    ActiveRecord::Base.transaction do
      cadets.each { |cadet| graduate_user!(cadet, @assignments[cadet.id]) }

      unit.end_assignments
      unit.update!(active: false)
    end

    cadets.each(&method(:queue_background_jobs)) # unless txn fails?
  rescue ActiveRecord::RecordInvalid
    false
  end

  private

  def verify_eligibility!(user)
    if user.member? || !user.assigned_to_unit?(unit) || !unit.enlistments.accepted.exists?(user: user)
      raise IneligibleCadet.new(user: user)
    end
  end

  def graduate_user!(user, assignment_unit_id)
    user.assignments.build(unit_id: assignment_unit_id, position_id: position_id,
      start_date: Date.current)

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
