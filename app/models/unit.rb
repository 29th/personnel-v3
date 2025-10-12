class Unit < ApplicationRecord
  audited max_audits: 10
  include UnitLogoImageUploader::Attachment(:logo)
  include FriendlyId
  friendly_id :prepare_slug

  has_ancestry orphan_strategy: :restrict
  has_many :assignments
  has_many :users, through: :assignments
  has_many :permissions
  has_many :unit_forum_roles
  has_many :events, inverse_of: "unit"
  has_many :enlistments

  enum :game, {dh: "DH", rs: "RS", arma3: "Arma 3", rs2: "RS2", squad: "Squad"}
  enum :timezone, {est: "EST", gmt: "GMT", pst: "PST"}
  enum :classification, {combat: "Combat", staff: "Staff", training: "Training"}

  scope :active, -> { where(active: true) }
  scope :for_dropdown, ->(current_value = nil) {
    collection = active.order(:ancestry, :name)
    current_value.present? ? collection.including(current_value).uniq : collection
  }
  scope :training_platoons, -> {
    # Don't include the stub parent unit that houses all the TPs
    training.where.not(name: "Training Platoons")
  }
  scope :with_event_range, -> {
    # Used by Process Enlistment action to show date range of training platoons
    select("units.*, (SELECT CONCAT( DATE_FORMAT(MIN(starts_at),'%d %b %Y'),' - ', DATE_FORMAT(MAX(starts_at),'%d %b %Y')) FROM events WHERE events.unit_id = `units`.id) AS event_range")
  }
  scope :ordered_squads, -> {
    active
      .combat
      .order(:abbr)
      .ransack({name_i_cont: "Squad"})
      .result(distinct: true)
  }
  scope :with_assignment_count, -> {
    with(assignment_counts: Assignment.active.count_by_unit)
      .left_joins(:assignment_counts)
      .select("*")
      .select(assignment_counts: [:assignment_count])
  }

  nilify_blanks
  validates :name, presence: true
  validates :abbr, presence: true, length: {maximum: 24}
  validates :classification, presence: true
  validates :slogan, length: {maximum: 140}

  before_save :update_path_from_ancestry

  def to_s
    abbr
  end

  def display_name
    abbr
  end

  def self.find_root
    active.where(ancestry: nil, classification: :combat).first
  end

  # abbr that applies to the entire subtree
  # e.g. 'Charlie Co.' instead of 'Charlie Co. HQ"
  def subtree_abbr
    abbr.gsub(/ HQ$/, "")
  end

  # NOTE: You probably want to add .active when using this,
  #       to only get active users
  def subtree_users
    User.joins(:assignments)
      .where(assignments: {unit_id: subtree.ids})
  end

  def end_assignments
    assignments.active.update_all(end_date: Date.today)
  end

  def prepare_slug
    if staff?
      name
    else
      abbr&.sub(/ Co. HQ$/, "")&.sub(/ HQ$/, "")
    end
  end

  def v2_slug
    abbr&.gsub(/ Co| HQ|[ \.]/, "")
  end

  def attendance_stats
    @attendance_stats ||= Rails.cache.fetch("units/#{id}/attendance_stats",
      expires_in: 1.hour) do
      AttendanceStats.for_unit(subtree)
    end
  end

  # the database uses a column named `class`, which is a reserved
  # word in ruby. this hack prevents it breaking the app.
  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name == "class"
      super
    end
  end

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name abbr game timezone active ancestry classification]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[ancestors]
  end

  private

  def update_path_from_ancestry
    # path is still used by v2, and is identical to ancestry, plus surrounding slashes
    self.path = "/#{ancestry}/" if ancestry_changed?
  end
end
