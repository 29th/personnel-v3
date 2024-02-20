class Rank < ApplicationRecord
  audited
  include RankImageUploader::Attachment(:image)

  validates_presence_of :name, :abbr, :order
  validates_numericality_of :order, only_integer: true

  scope :officer, -> { where("grade LIKE 'O-%'") }
  scope :enlisted, -> { where("grade LIKE 'E-%' OR grade = ''") }

  def display_name
    abbr
  end

  def slug
    abbr.gsub(/[^0-9a-zA-Z]/i, "").downcase
  end

  def officer?
    grade&.starts_with? "O-"
  end

  def self.recruit
    find_by!(name: "Recruit")
  end

  private_class_method :ransackable_attributes

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name abbr grade]
  end
end
