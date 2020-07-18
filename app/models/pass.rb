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

  def self.ransackable_attributes(_auth_object)
    %w[type start_date end_date]
  end

  def self.ransortable_attributes(_auth_object)
    %w[start_date end_date type]
  end

  def self.ransackable_associations(_auth_object)
    %w[user]
  end

  def self.ransackable_scopes(_auth_object)
    %i[active]
  end

  def set_add_date
    self.add_date = Date.current
  end
end
