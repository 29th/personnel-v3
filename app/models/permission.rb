class Permission < ApplicationRecord
  self.table_name = "unit_permissions"
  audited
  enum :access_level, {member: 0, elevated: 5, leader: 10}

  belongs_to :unit
  belongs_to :ability

  validates_presence_of :unit, :ability, :access_level
  validates :ability, uniqueness: {scope: [:unit, :access_level], message: "Permission combination already exists"}

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id access_level]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[unit ability]
  end
end
