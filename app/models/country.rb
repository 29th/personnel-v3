class Country < ApplicationRecord
  validates :abbr, presence: true, length: {maximum: 2},
    format: {with: /\A[A-Z]+\Z/}
  validates :name, presence: true

  default_scope -> { order(:name) }

  def sym
    abbr.downcase.to_sym
  end

  private_class_method :ransackable_attributes

  def self.ransackable_attributes(_auth_object)
    %w[id abbr name]
  end
end
