class Event < ApplicationRecord
  self.inheritance_column = nil # don't treat type field as STI
  belongs_to :unit
  belongs_to :server

  scope :by_user, -> (user) do
    unit_ids = user.assignments
                   .active
                   .includes(:unit)
                   .flat_map { |assignment| assignment.unit.path_ids }
                   .uniq

    where(unit: unit_ids)
  end

  # TODO: Clean up data and convert field to enum
  validates :type, presence: true

  validates :datetime, presence: true
  validates_datetime :datetime
  validates :mandatory, inclusion: { in: [true, false] }
  validates :server, presence: true

  def title
    "#{unit.abbr} #{type}"
  end

  def self.ransackable_attributes(_auth_object)
    %w[datetime]
  end

  def self.ransortable_attributes(_auth_object)
    %w[datetime type mandatory]
  end

  def self.ransackable_associations(_auth_object)
    %w[unit]
  end

  # Allow filtering a datetime field by a date
  ransacker :datetime do
    Arel.sql('date(datetime)')
  end

  # Alias for simple_calendar
  def start_time
    datetime
  end
end
