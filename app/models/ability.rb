class Ability < ApplicationRecord
  has_many :permissions
  audited

  validates_presence_of :name, :abbr

  def display_name
    abbr
  end
  
  private

  def self.ransackable_attributes(_auth_object)
    %w(id name abbr)
  end
  
  def self.ransackable_associations(_auth_object)
    %w(permissions)
  end
end
