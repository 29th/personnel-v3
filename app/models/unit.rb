class Unit < ApplicationRecord
  audited max_audits: 10
  include UnitLogoImageUploader::Attachment(:logo)

  has_ancestry orphan_strategy: :restrict
  has_many :assignments
  has_many :users, through: :assignments
  has_many :permissions
  has_many :unit_forum_roles

  enum game: {dh: "DH", rs: "RS", arma3: "Arma 3", rs2: "RS2", squad: "Squad"}
  enum timezone: {est: "EST", gmt: "GMT", pst: "PST"}
  enum classification: {combat: "Combat", staff: "Staff", training: "Training"}

  scope :active, -> { where(active: true) }
  scope :for_dropdown, -> { active.order(:ancestry, :name) }

  nilify_blanks
  validates :name, presence: true
  validates :abbr, presence: true, length: {maximum: 12}
  validates :classification, presence: true
  validates :slogan, length: {maximum: 140}

  before_save :update_path_from_ancestry

  def display_name
    abbr
  end

  def slug
    abbr.delete(" ").downcase
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

  # the database uses a column named `class`, which is a reserved
  # word in ruby. this hack prevents it breaking the app.
  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name == "class"
      super
    end
  end

  private

  def self.ransackable_attributes(_auth_object)
    %w(id name abbr game timezone active ancestry classification)
  end
  
  def self.ransackable_associations(_auth_object)
    %w(ancestors)
  end

  def update_path_from_ancestry
    # path is still used by v2, and is identical to ancestry, plus surrounding slashes
    self.path = "/#{ancestry}/" if ancestry_changed?
  end
end
