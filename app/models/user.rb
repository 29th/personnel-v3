class User < ApplicationRecord
  include FriendlyId
  include ServiceCoatUploader::Attachment(:service_coat)

  self.table_name = "members"
  self.ignored_columns = %w[status primary_assignment_id im_type im_handle city]
  audited max_audits: 10
  friendly_id :slug_candidates

  has_many :assignments, dependent: :delete_all, foreign_key: "member_id"
  has_many :active_assignments, -> {
    where("assignments.start_date <= ?", Date.today)
      .merge(where("assignments.end_date > ?", Date.today).or(where(end_date: nil)))
  }, class_name: "Assignment", foreign_key: "member_id"

  has_many :non_training_assignments, -> {
    joins(:unit).where.not(units: {classification: "Training"})
  }, class_name: "Assignment", foreign_key: "member_id"

  has_many :user_awards, foreign_key: "member_id"
  has_many :awards, through: :user_awards
  has_many :demerits, foreign_key: "member_id"
  has_many :discharges, foreign_key: "member_id"
  has_many :non_honorable_discharges, -> { non_honorable },
    class_name: "Discharge", foreign_key: "member_id"
  has_one :latest_non_honorable_discharge, -> {
    non_honorable.order(date: :desc).limit(1)
  }, class_name: "Discharge", foreign_key: "member_id"

  has_many :enlistments, foreign_key: "member_id", inverse_of: :user
  has_many :extended_loas, foreign_key: "member_id"
  has_many :finance_records, foreign_key: "member_id"
  has_many :notes, foreign_key: "member_id"
  has_many :passes, inverse_of: :user, foreign_key: "member_id"
  has_many :promotions, foreign_key: "member_id"
  has_many :units, through: :assignments
  has_many :ait_qualifications, foreign_key: "member_id"
  has_many :ait_standards, through: :ait_qualifications
  has_many :attendance_records, foreign_key: "member_id"
  has_many :recruited_enlistments, class_name: "Enlistment",
    foreign_key: "recruiter_member_id", inverse_of: :recruiter_user
  has_many :accepted_recruited_enlistments, -> { accepted },
    class_name: "Enlistment", foreign_key: "recruiter_member_id"
  belongs_to :rank
  belongs_to :country, optional: true

  scope :active, ->(date = Date.current) {
    joins(:assignments).merge(Assignment.active(date)).distinct
  }

  scope :honorably_discharged, -> {
    where.not(id: Assignment.active.select(:member_id))
      .joins(:discharges)
      .where(
        "discharges.date = (SELECT MAX(d2.date) FROM discharges d2 WHERE d2.member_id = members.id)"
      )
      .where(discharges: {type: "Honorable"})
      .distinct
  }

  attr_accessor :username

  nilify_blanks
  normalizes :first_name, :last_name, :steam_id, with: ->(attribute) { attribute.strip }
  normalizes :middle_name, with: ->(middle_name) { middle_name.strip[0] }
  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :first_name, presence: true, length: {in: 1..30}
  validates :last_name, presence: true, length: {in: 2..40}
  validate :last_name_not_restricted

  validates :rank, presence: true
  validates :steam_id, presence: true, numericality: {only_integer: true}, length: {maximum: 17}

  validates :forum_member_id, uniqueness: true, allow_nil: true
  validates :forum_member_id, presence: true, on: :create
  validate :known_time_zone

  def self.from_sso(sso_data)
    find_or_initialize_by(forum_member_id: sso_data["uid"]) do |user|
      user.username = sso_data["info"]["nickname"]
      user.email = sso_data["info"]["email"]
      user.time_zone = sso_data["info"]["time_zone"]
      user.rank = Rank.recruit
    end
  end

  # Unregistered users have never enlisted, thus do not have a record in the
  # members table
  def unregistered? = !persisted?

  def full_name
    middle_initial = "#{middle_name.first}." if middle_name.present?

    [first_name, middle_initial, last_name]
      .reject(&:nil?)
      .join(" ")
  end

  def full_name_last_first
    middle_initial = "#{middle_name.first}." if middle_name.present?

    ["#{last_name},", first_name, middle_initial]
      .reject(&:nil?)
      .join(" ")
  end

  def short_name
    prefix = name_prefix.present? ? name_prefix + "." : nil
    [rank.abbr, prefix, last_name]
      .reject(&:nil?)
      .join(" ")
  end

  def to_s
    persisted? ? short_name : username
  end

  # For active admin
  def display_name
    short_name
  end

  def on_extended_loa?(date = Date.current)
    extended_loas.any? { |eloa| eloa.active?(date) }
  end

  def has_permission?(permission)
    @permissions ||= permissions.pluck("abilities.abbr")
    @permissions.include?(permission)
  end

  def has_permission_on_unit?(permission, unit)
    permissions_on_unit(unit).pluck("abilities.abbr").include?(permission)
  end

  def has_permission_on_user?(permission, user)
    return false if id == user.id # deny permissions on self
    permissions_on_user(user).pluck("abilities.abbr").include?(permission)
  end

  def active_admin_editor?
    has_permission?("manage")
  end

  def status
    if member?
      :member
    elsif cadet?
      :cadet
    elsif honorably_discharged?
      :retired
    elsif discharged?
      :discharged
    else
      :none
    end
  end

  def status_detail
    if active_assignments.any?
      active_assignments
        .map { |assignment| assignment.unit.abbr }
        .uniq
        .join(", ")
    elsif discharges.any?
      last_discharge = discharges.max_by(&:date)
      "#{last_discharge.type_abbr} #{last_discharge.date}"
    else
      ""
    end
  end

  def member?
    @member ||= assignments.active
      .joins(:unit)
      .where(units: {classification: %i[combat staff]})
      .any?
  end

  def discharged?
    assignments.active.size.zero? &&
      discharges.size >= 1
  end

  def honorably_discharged?
    discharged? && discharges.order("date").last.honorable?
  end

  def cadet?
    assignments.active.training.any?
  end

  def has_pending_enlistment?
    enlistments.pending.any?
  end

  def assigned_to_unit?(unit)
    active_assignments.exists?(unit: unit)
  end

  def assigned_to_subtree?(unit)
    active_assignment_unit_path_ids.include? unit.id
  end

  def active_assignment_unit_path_ids
    @active_assignment_unit_path_ids ||= assignments
      .active
      .includes(:unit)
      .flat_map { |assignment| assignment.unit.path_ids }
      .uniq
  end

  # Calculate service duration
  # To avoid N+1 queries, ensure non_training_assignments and latest_non_honorable_discharge are preloaded
  def service_duration
    # Don't include training assignments in service duration
    relevant_assignments = non_training_assignments

    # Filter assignments since last non-honorable discharge if applicable
    if latest_non_honorable_discharge.present?
      # Filter in memory instead of using the since scope to avoid N+1 queries
      discharge_date = latest_non_honorable_discharge.date
      relevant_assignments = relevant_assignments.select { |a| a.start_date >= discharge_date }
    end

    days_of_service = relevant_assignments
      .map { |assignment| assignment.period.to_a } # get all dates in period
      .flatten
      .uniq
      .count

    seconds_of_service = days_of_service * 24 * 60 * 60
    ActiveSupport::Duration.build(seconds_of_service)
  end

  def attendance_stats
    @attendance_stats ||= AttendanceStats.for_user(self)
  end

  def forum_member_username
    @forum_member_username ||= discourse_service.user.username if forum_member_id.present?
  end

  def forum_member_email
    @forum_member_email ||= discourse_service.user.email if forum_member_id.present?
  end

  def create_forum_topic(...) = discourse_service.user.create_topic(...)

  def linked_forum_users
    @linked_forum_users ||= begin
      linked_forum_users = []
      if forum_member_id
        discourse_users = discourse_service.user.linked_users
        linked_forum_users.concat(discourse_users)
      end
      if vanilla_forum_member_id
        vanilla_users = [{user_id: vanilla_forum_member_id, forum: :vanilla, username: nil, ips: []}]
        linked_forum_users.concat(vanilla_users)
      end
      linked_forum_users
    end
  end

  def refresh_rank
    latest_promotion = promotions.order(date: :desc).first
    if latest_promotion
      update(rank: latest_promotion.new_rank)
    else
      default_rank = Rank.find_by_abbr("Pvt.")
      update(rank: default_rank)
    end
  end

  def end_assignments(end_date = Date.current)
    assignments.active.each { |assignment| assignment.end(end_date) }
  end

  def forum_role_ids(forum)
    (special_forum_roles(forum) + unit_forum_roles(forum))
      .pluck(:role_id)
      .uniq
      .sort
  end

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id last_name first_name steam_id forum_member_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[rank country]
  end

  private

  def discourse_service
    @discourse_service ||= DiscourseService.new(forum_member_id)
  end

  def slug_candidates
    [
      [:name_prefix, :last_name],
      :full_name,
      [:last_name, :id]
    ]
  end

  def permissions
    # TODO: Use Ability instead of assignments? Doesn't matter much...
    assignments.active
      .joins(:position, unit: {permissions: :ability})
      .where("unit_permissions.access_level <= positions.access_level")
      .where("units.active", true)
  end

  def permissions_on_unit(unit)
    permissions.where(unit: unit.path_ids)
  end

  def permissions_on_user(subject)
    subject_path_ids = subject.active_assignment_unit_path_ids

    permissions.where(unit: subject_path_ids)
  end

  def special_forum_roles(forum)
    special_attributes = []
    special_attributes << "everyone"
    special_attributes << "member" if member?
    special_attributes << "honorably_discharged" if honorably_discharged?
    special_attributes << "officer" if rank.officer?

    SpecialForumRole.where(special_attribute: special_attributes, forum_id: forum)
  end

  def unit_forum_roles(forum)
    assignments.active
      .joins(:position, unit: :unit_forum_roles)
      .where("unit_roles.access_level <= positions.access_level")
      .where("unit_roles.forum_id = ?", UnitForumRole.forum_ids[forum])
      .where("units.active", true)
      .select("unit_roles.id", "unit_roles.role_id",
        "unit_roles.access_level", "unit_roles.unit_id")
  end

  def known_time_zone
    if time_zone? && !ActiveSupport::TimeZone[time_zone].present?
      errors.add(:time_zone, "is not known")
    end
  end

  def last_name_not_restricted
    if RestrictedName.where(name: last_name).where.not(user: self).exists?
      errors.add(:last_name, "is already taken")
    end
  end
end
