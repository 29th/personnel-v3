class Award < ApplicationRecord
  audited
  include AwardImageUploader::Attachment(:presentation_image)
  include AwardImageUploader::Attachment(:ribbon_image)

  has_many :user_awards
  has_many :users, through: :user_awards

  enum :game, {notapplicable: "N/A", dh: "DH", rs: "RS", arma3: "Arma 3", rs2: "RS2", squad: "Squad"}

  validates :code, presence: true
  validates :title, presence: true
  validates :game, presence: true
  validates :description, presence: true

  validates :active, inclusion: [true, false]
  validates :order, numericality: {only_integer: true}, if: :present?

  scope :active, -> { where(active: true) }

  private_class_method :ransackable_attributes

  def self.ransackable_attributes(_auth_object = nil)
    %w[id code title game active]
  end
end
