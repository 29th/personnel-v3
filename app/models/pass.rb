class Pass < ApplicationRecord
  self.inheritance_column = nil # don't treat type field as STI
  belongs_to :user, foreign_key: 'member_id'
  belongs_to :author, class_name: 'User'
  belongs_to :recruit, class_name: 'User', optional: true

  enum type: { recruitment: 'Recruitment',
               recurring_donation: 'Recurring Donation',
               award: 'Award',
               other: 'Other' }

  validates :type, presence: true
  validates :reason, presence: true, length: { maximum: 255 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_cannot_be_before_start_date

  scope :active, -> { where('start_date <= ? AND end_date >= ?', Date.current, Date.current) }

  private

  def end_date_cannot_be_before_start_date
    if start_date? && end_date? && end_date < start_date
      errors.add(:end_date, "can't be before start date")
    end
  end
end
