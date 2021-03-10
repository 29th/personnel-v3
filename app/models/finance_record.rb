class FinanceRecord < ApplicationRecord
  self.table_name = 'finances'
  audited
  belongs_to :user, foreign_key: 'member_id'

  enum vendor: { notapplicable: 'N/A',
                 game_servers: 'Game Servers',
                 branzone: 'Branzone',
                 dreamhost: 'Dreamhost',
                 nuclear_fallout: 'Nuclear Fallout',
                 other: 'Other',
                 digital_ocean: 'Digital Ocean, Inc',
                 google: 'Google' }

  enum forum_id: { phpbb: 'PHPBB',
                   smf: 'SMF',
                   vanilla: 'Vanilla',
                   discourse: 'Discourse' }

  validates :date, presence: true
  validates_date :date
  validates :user, presence: true
  validates :forum_id, presence: true, if: -> { topic_id.present? }
  validates :topic_id, numericality: { only_integer: true }, allow_nil: true
  validates :notes, presence: true
  validates :amount_received, numericality: true, allow_nil: true
  validates :amount_paid, numericality: true, allow_nil: true
  validates :fee, numericality: true, allow_nil: true
  validate :received_or_paid

  scope :income, -> { where('amount_received > 0') }
  scope :expenses, -> { where('amount_paid > 0') }

  def self.balance
    FinanceRecord.select('SUM(amount_received) - SUM(amount_paid) - SUM(fee) AS balance')
                 .first
                 .balance
  end

  private

  def received_or_paid
    unless amount_received.blank? ^ amount_paid.blank?
      errors.add(:base, 'Specify an amount received or paid, not both')
    end
  end
end
