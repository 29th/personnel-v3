class UnitForumRole < ApplicationRecord
  audited
  self.table_name = "unit_roles"
  belongs_to :unit

  enum :access_level, {member: 0, elevated: 5, leader: 10}

  enum :forum_id, {vanilla: "Vanilla",
                  discourse: "Discourse"}

  validates :forum_id, presence: true
  validates :access_level, presence: true
  validates :role_id, presence: true
  validates :role_id, numericality: {only_integer: true}

  attr_accessor :discourse_role_id, :vanilla_role_id

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id access_level forum_id role_id]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[unit]
  end
end
