class Pass < ApplicationRecord
  self.inheritance_column = nil # don't treat type field as STI
  belongs_to :user, foreign_key: 'member_id'
  belongs_to :author, class_name: 'User'
  belongs_to :recruit, class_name: 'User', optional: true

  attr_accessor :bulk_member_ids

  enum type: { recruitment: 'Recruitment',
               recurring_donation: 'Recurring Donation',
               award: 'Award',
               other: 'Other' }

  validates :type, presence: true
  validates :reason, presence: true, length: { maximum: 255 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates_date :start_date
  validates_date :end_date, after: :start_date

  before_create :set_add_date

  scope :active, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }

  private

  def set_add_date
    self.add_date = Date.current
  end
end
