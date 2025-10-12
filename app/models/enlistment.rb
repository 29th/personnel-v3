class Enlistment < ApplicationRecord
  include HasForumTopic
  include StoreModel::NestedAttributes
  audited
  belongs_to :user, foreign_key: "member_id", inverse_of: :enlistments
  belongs_to :liaison, class_name: "User", foreign_key: "liaison_member_id",
    optional: true
  belongs_to :recruiter_user, class_name: "User", foreign_key: "recruiter_member_id",
    optional: true # There's already a column called recruiter
  belongs_to :country, optional: true
  belongs_to :unit, optional: true

  enum :status, {pending: "Pending", accepted: "Accepted", denied: "Denied",
                withdrawn: "Withdrawn", awol: "AWOL"}
  enum :timezone, {est: "EST", gmt: "GMT", pst: "PST", any_timezone: "Any", no_timezone: "None"}
  enum :game, {dh: "DH", rs: "RS", arma3: "Arma 3", rs2: "RS2", squad: "Squad"}
  VALID_AGES = ["Under 13", *13..99].map(&:to_s)

  normalizes :ingame_name, :recruiter, :comments, with: ->(attribute) { attribute.strip }

  validates :user, presence: true
  accepts_nested_attributes_for :user, update_only: true
  validates_associated :user

  validates :date, timeliness: {date: true}
  validates :status, presence: true
  validates :age, presence: true, inclusion: {in: VALID_AGES, message: "not recognized"}
  validates :timezone, presence: true
  validates :game, presence: true
  validates :ingame_name, presence: true, length: {maximum: 60}
  validates :discord_username, length: {maximum: 64}
  validates :experience, presence: true, length: {maximum: 1500}
  validates :recruiter, length: {maximum: 128}
  validates :comments, length: {maximum: 1500}
  validate :unit_classification_is_training

  attribute :previous_units, PreviousUnit.to_array_type, default: -> { [] }
  accepts_nested_attributes_for :previous_units, allow_destroy: true, reject_if: :all_blank
  validates_associated :previous_units, store_model: {merge_array_errors: true}

  delegate :linked_forum_users, to: :user

  before_validation :set_legacy_attributes_from_user

  scope :with_recruiter_details, -> { includes(recruiter_user: [:rank, active_assignments: :unit]) }

  scope :with_recruit_result, -> {
    select("enlistments.*")
      .select(
        'CASE
        WHEN EXISTS (
          SELECT 1 FROM promotions
          JOIN ranks ON promotions.new_rank_id = ranks.id
          WHERE promotions.member_id = enlistments.member_id
          AND ranks.order > 2 -- Greater than Private
          AND promotions.date > enlistments.date
        ) THEN "Promoted"
        WHEN EXISTS (
          SELECT 1 FROM assignments
          JOIN units ON assignments.unit_id = units.id
          WHERE assignments.member_id = enlistments.member_id
          AND units.classification = "Combat"
          AND assignments.start_date > enlistments.date
        ) THEN "Graduated"
        ELSE "Accepted"
       END AS result'
      )
  }

  def linked_ban_logs
    ips = linked_forum_users.pluck(:ips).flatten.uniq

    query = {m: "or"} # use OR instead of default AND
    query[:roid_in] = steam_ids
    query[:handle_i_cont] = ingame_name
    query[:ip_in] = ips unless ips.empty?

    BanLog.ransack(query).result(distinct: true)
  end

  def linked_users_by_steam_id
    User
      .includes(:rank)
      .ransack(steam_id_in: steam_ids, id_not_eq: user.id)
      .result(distinct: true)
  end

  def users_with_matching_name
    User
      .includes(:rank, :discharges, active_assignments: :unit)
      .ransack(last_name_start: last_name, id_not_eq: user.id)
      .result(distinct: true)
  end

  def create_assignment!
    recruit = Position.recruit
    Assignment.create!(user: user, unit: unit, start_date: Date.current,
      position: recruit)
  end

  def end_assignments
    active_training_assignments.each(&:end)
  end

  def destroy_assignments
    active_training_assignments.destroy_all
  end

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id date game timezone status game timezone]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user liaison recruiter_user unit]
  end

  private

  def steam_ids
    [steam_id, user.steam_id].uniq # enlistment steam id may differ
  end

  def active_training_assignments
    user.assignments.active.training
  end

  # backwards compatibility - can be removed after full transition
  def set_legacy_attributes_from_user
    legacy_attributes = [:first_name, :middle_name, :last_name, :country, :steam_id]
    assign_attributes(user.slice(legacy_attributes))
  end

  def unit_classification_is_training
    if unit.present? && !unit.training?
      errors.add(:unit_id, "must be a training unit")
    end
  end
end
