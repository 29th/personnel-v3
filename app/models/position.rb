class Position < ApplicationRecord
  audited
  enum access_level: {member: 0, elevated: 5, leader: 10}
  enum AIT: {leadership: "Leadership",
             rifle: "Rifle",
             submachine_gun: "Submachine Gun",
             automatic_rifle: "Automatic Rifle",
             combat_engineer: "Combat Engineer",
             machine_gun: "Machine Gun",
             armor: "Armor",
             mortar: "Mortar",
             pilot: "Pilot",
             sniper: "Sniper",
             not_applicable: "N/A",
             grenadier: "Grenadier"}

  validates :name, presence: true, length: {maximum: 250}
  validates :order, numericality: {only_integer: true}, allow_nil: true

  scope :active, -> { where(active: true) }
end
