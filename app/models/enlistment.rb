class Enlistment < ApplicationRecord
  include HasForumTopic
  include StoreModel::NestedAttributes
  audited
  belongs_to :user, foreign_key: "member_id"
  belongs_to :liaison, class_name: "User", foreign_key: "liaison_member_id",
    optional: true
  belongs_to :recruiter_user, class_name: "User", foreign_key: "recruiter_member_id",
    optional: true # There's already a column called recruiter
  belongs_to :country
  belongs_to :unit, optional: true

  enum status: {pending: "Pending", accepted: "Accepted", denied: "Denied",
                withdrawn: "Withdrawn", awol: "AWOL"}
  enum timezone: {est: "EST", gmt: "GMT", pst: "PST", any_timezone: "Any", no_timezone: "None"}
  enum game: {dh: "DH", rs: "RS", arma3: "Arma 3", rs2: "RS2", squad: "Squad"}
  VALID_AGES = ["Under 13", *13..99].map(&:to_s)

  normalizes :middle_name, with: ->(middle_name) { middle_name.strip[0] }

  validates :user, presence: true
  validates :date, timeliness: {date: true}
  validates :first_name, presence: true, length: {in: 1..30}
  validates :middle_name, length: {maximum: 1}
  validates :last_name, presence: true, length: {in: 2..40}
  validate :last_name, :last_name_not_restricted
  validates :age, presence: true, inclusion: {in: VALID_AGES, message: "not recognized"}
  validates :timezone, presence: true
  validates :game, presence: true
  validates :ingame_name, length: {maximum: 60}
  validates :steam_id, presence: true, numericality: {only_integer: true}, length: {maximum: 17}
  validates :experience, presence: true, length: {maximum: 1500}
  validates :recruiter, length: {maximum: 128}
  validates :comments, length: {maximum: 1500}

  attribute :previous_units, PreviousUnit.to_array_type, default: -> { [] }
  accepts_nested_attributes_for :previous_units, allow_destroy: true, reject_if: :all_blank
  validates_associated :previous_units, store_model: {merge_array_errors: true}

  before_create :set_date
  before_validation :shorten_middle_name

  def linked_users
    @linked_vanilla_users ||= VanillaService.new.get_linked_users(user.vanilla_forum_member_id) if user&.vanilla_forum_member_id
  end

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id date game timezone status game timezone]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user liaison recruiter_user unit]
  end

  private

  def set_date
    self.date = Date.current
  end

  def shorten_middle_name
    self.middle_name = middle_name ? middle_name[0] : ""
  end

  def last_name_not_restricted
    if RestrictedName.where(name: last_name).where.not(user: user).exists?
      errors.add(:last_name, "is already taken")
    end
  end
end
