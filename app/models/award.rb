class Award < ApplicationRecord
  has_many :user_awards
  has_many :users, through: :user_awards

  enum game: { notapplicable: 'N/A', dh: 'DH', rs: 'RS', arma3: 'Arma 3', rs2: 'RS2', squad: 'Squad' }

  validates :code, presence: true
  validates :title, presence: true
  validates :game, presence: true
  validates :description, presence: true

  validates :image, presence: true
  validates :image, format: { with: URI.regexp }, if: :present?

  validates :thumbnail, presence: true
  validates :thumbnail, format: { with: URI.regexp }, if: :present?

  validates :bar, presence: true
  validates :bar, format: { with: URI.regexp }, if: :present?

  # validates :active, inclusion: { in: [true, false] }, if: :present?
  validates :order, numericality: { only_integer: true }, if: :present?

  scope :active, -> { where(active: true) }
end
