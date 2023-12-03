class FinanceRecord < ApplicationRecord
  self.table_name = "finances"
  include HasForumTopic
  audited
  belongs_to :user, foreign_key: "member_id", optional: true

  enum vendor: {notapplicable: "N/A",
                game_servers: "Game Servers",
                branzone: "Branzone",
                dreamhost: "Dreamhost",
                nuclear_fallout: "Nuclear Fallout",
                other: "Other",
                digital_ocean: "Digital Ocean, Inc",
                google: "Google"}

  validates :date, presence: true
  validates_date :date
  validates :amount_received, numericality: true, allow_nil: true
  validates :amount_paid, numericality: true, allow_nil: true
  validates :fee, numericality: true, allow_nil: true
  validate :received_or_paid

  scope :income, -> { where("amount_received > 0") }
  scope :expenses, -> { where("amount_paid > 0") }
  scope :by_user, ->(user) { where(user: user) }

  def self.balance
    FinanceRecord.select("SUM(amount_received) - SUM(amount_paid) - SUM(fee) AS balance")
      .first
      .balance
  end

  def self.user_donated(user)
    income.by_user(user).sum(:amount_received)
  end

  private

  def self.ransackable_attributes(_auth_object)
    %w(id date vendor amount_received amount_paid fee)
  end

  def self.ransackable_associations(_auth_object)
    %w(user)
  end

  def received_or_paid
    unless amount_received.blank? ^ amount_paid.blank?
      errors.add(:base, "Specify an amount received or paid, not both")
    end
  end
end
