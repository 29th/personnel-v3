class PreviousUnit < ApplicationRecord
  belongs_to :enlistment

  validates :unit, presence: true, length: {maximum: 64}
  validates :game, length: {maximum: 64}
  validates :name, length: {maximum: 64}
  validates :rank, length: {maximum: 64}
  validates :reason, presence: true, length: {maximum: 256}
end
