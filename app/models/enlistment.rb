class Enlistment < ApplicationRecord
  include HasForumTopic
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

  validates :user, presence: true
  validates :date, timeliness: {date: true}
  validates :first_name, presence: true, length: {in: 1..30}
  validates :middle_name, length: {maximum: 1}
  validates :last_name, presence: true, length: {in: 2..40}
  validate :last_name, :last_name_not_restricted
  validates :age, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 13, less_than_or_equal_to: 99}
  validates :timezone, presence: true
  validates :game, presence: true
  validates :ingame_name, length: {maximum: 60}
  validates :steam_id, numericality: {only_integer: true} # validate length?
  validates :experience, presence: true
  validates :recruiter, length: {maximum: 128}

  serialize :previous_units, coder: PreviousUnit::ArraySerializer
  validates_associated :previous_units

  before_create :set_date
  before_validation :shorten_middle_name

  def linked_users
    @linked_users ||= begin
      linked_users = []
      if user&.forum_member_id
        discourse_users = DiscourseService.new.get_linked_users(user.forum_member_id)
        linked_users.concat(discourse_users)
      end
      if user&.vanilla_forum_member_id
        vanilla_users = VanillaService.new.get_linked_users(user.vanilla_forum_member_id)
        linked_users.concat(vanilla_users)
      end
      linked_users
    end
  end

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object)
    %w[id date game timezone status game timezone]
  end

  def self.ransackable_associations(_auth_object)
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
