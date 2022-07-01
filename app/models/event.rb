class Event < ApplicationRecord
  self.inheritance_column = nil # don't treat type field as STI
  belongs_to :unit
  belongs_to :server
  belongs_to :reporter, foreign_key: "reporter_member_id", class_name: "User", optional: true
  has_many :attendance_records, -> { includes(user: :rank).order("ranks.order DESC", "members.last_name") }

  scope :by_user, ->(user) do
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
  validates :mandatory, inclusion: {in: [true, false]}
  validates :server, presence: true

  def title
    if unit
      "#{unit.subtree_abbr} #{type}"
    else
      type
    end
  end

  # Alias for simple_calendar
  def start_time
    datetime
  end
end
