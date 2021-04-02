class User < ApplicationRecord
  self.table_name = "members"
  audited max_audits: 10

  has_many :assignments, dependent: :delete_all, foreign_key: "member_id"
  has_many :awards, through: :user_awards
  has_many :demerits, foreign_key: "member_id"
  has_many :discharges, foreign_key: "member_id"
  has_many :extended_loas, foreign_key: "member_id"
  has_many :finance_records, foreign_key: "member_id"
  has_many :notes, foreign_key: "member_id"
  has_many :passes, inverse_of: :user, foreign_key: "member_id"
  has_many :promotions, foreign_key: "member_id"
  has_many :units, through: :assignments
  has_many :user_awards, foreign_key: "member_id"
  belongs_to :rank
  belongs_to :country, optional: true

  scope :active, -> { joins(:assignments).merge(Assignment.active).distinct }
  scope :for_dropdown, -> { active.includes(:rank).order(:last_name) }

  nilify_blanks
  validates_presence_of :last_name, :first_name, :rank
  validates :discourse_forum_member_id, uniqueness: true, allow_nil: true

  def full_name
    middle_initial = "#{middle_name.first}." if middle_name.present?

    [first_name, middle_initial, last_name]
      .reject(&:nil?)
      .join(" ")
  end

  def short_name
    [rank.abbr, name_prefix, last_name]
      .reject(&:nil?)
      .join(" ")
  end

  def to_s
    short_name
  end

  # For active admin
  def display_name
    short_name
  end

  def self.create_with_auth(auth)
    create! do |user|
      user.steam_id = auth["uid"]
    end
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

  def member?
    assignments.active
      .joins(:unit)
      .where(units: {classification: %i[combat staff]})
      .any?
  end

  def honorably_discharged?
    assignments.active.size.zero? &&
      discharges.size >= 1 &&
      discharges.order("date").last.honorable?
  end

  def forum_role_ids(forum)
    (special_forum_roles(forum) + unit_forum_roles(forum))
      .pluck(:role_id)
      .uniq
      .sort
  end

  def update_coat
    PersonnelV2Service.new.update_coat(id)
  end

  def update_forum_display_name
    DiscourseService.new.update_user_display_name(self) if discourse_forum_member_id.present?
    VanillaService.new.update_user_display_name(self) if forum_member_id.present?
  end

  def update_forum_roles
    DiscourseService.new.update_user_roles(self) if discourse_forum_member_id.present?
    VanillaService.new.update_user_roles(self) if forum_member_id.present?
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

  private

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
    subject_path_ids = subject.assignments
      .active
      .includes(:unit)
      .flat_map { |assignment| assignment.unit.path_ids }
      .uniq

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
end
