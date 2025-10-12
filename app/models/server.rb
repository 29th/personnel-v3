class Server < ApplicationRecord
  has_many :events

  scope :active, -> { where(active: true) }
  scope :for_dropdown, -> { active.order(:game, :name) }

  enum :game, {dh: "DH", rs: "RS", arma3: "Arma 3", rs2: "RS2", squad: "Squad"}

  validates :name, presence: true
  validates :abbr, presence: true
  validates :address, presence: true
  validates :port, presence: true, numericality: {only_integer: true}
  validates :active, inclusion: [true, false]

  private_class_method :ransackable_attributes

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name abbr game]
  end
end
