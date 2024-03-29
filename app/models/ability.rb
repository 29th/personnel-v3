class Ability < ApplicationRecord
  has_many :permissions
  audited

  validates_presence_of :name, :abbr

  def display_name
    abbr
  end

  private_class_method :ransackable_attributes, :ransackable_associations

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name abbr]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[permissions]
  end
end
