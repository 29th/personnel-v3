class AITStandard < ApplicationRecord
  self.table_name = "standards"
  audited

  enum :weapon, {eib: "EIB", rifle: "Rifle", automatic_rifle: "Automatic Rifle",
                machine_gun: "Machine Gun", armor: "Armor", sniper: "Sniper",
                mortar: "Mortar", slt: "SLT", combat_engineer: "Combat Engineer",
                submachine_gun: "Submachine Gun", pilot: "Pilot", grenadier: "Grenadier"}
  enum :game, {dh: "DH", rs: "RS", arma3: "Arma 3", rs2: "RS2", squad: "Squad"}
  enum :badge, {notapplicable: "N/A", marksman: "Marksman", sharpshooter: "Sharpshooter",
               expert: "Expert"}

  validates :weapon, presence: true
  validates :game, presence: true
  validates :badge, presence: true
  validates :description, presence: true

  def to_s
    description
  end

  def with_prefix
    prefix = [game, weapon, badge].reject(&method(:nil_or_na)).join(":")
    "[#{prefix}] #{description}"
  end

  private_class_method :ransackable_attributes

  def self.ransackable_attributes(_auth_object = nil)
    %w[id weapon game badge]
  end

  private

  def nil_or_na(value)
    value.nil? || value == "notapplicable"
  end
end
