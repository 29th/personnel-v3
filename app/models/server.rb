class Server < ApplicationRecord
  scope :active, -> { where(active: true) }

  enum game: {dh: "DH", rs: "RS", arma3: "Arma 3", rs2: "RS2", squad: "Squad"}

  validates :name, presence: true
  validates :abbr, presence: true
  validates :address, presence: true
  validates :port, presence: true, numericality: {only_integer: true}
  validates :active, inclusion: [true, false]
end
