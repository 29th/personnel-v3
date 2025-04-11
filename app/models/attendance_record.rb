class AttendanceRecord < ApplicationRecord
  DISCHARGEABLE_PERIOD_DAYS = 30

  self.table_name = "attendance"
  belongs_to :user, foreign_key: "member_id"
  belongs_to :event

  scope :without_cancelled_loas, -> { where.not(attended: nil).or(where(excused: true)) }
  scope :awol, -> {
    includes(event: :unit)
      .where(attended: false, excused: false,
        event: {mandatory: true, starts_at: ..24.hours.ago})
      .where.not(unit: {classification: :training})
  }
  scope :totals_by_event, -> {
    group(:event_id)
      .select(:event_id)
      .select("sum(attended = true) as total_attended")
      .select("count(*) as total_expected")
      .select("sum(attended = false and excused = false) as total_absent")
  }
  scope :by_unit, ->(unit) {
    includes(:event)
      .where(event: {unit: unit})
  }
  scope :active_users, -> {
    joins(:user).merge(User.active)
  }
  scope :event_on_or_after, ->(date) {
    joins(:event).where({event: {starts_at: date..}})
  }

  validates :attended, inclusion: {in: [true, false]}, allow_nil: true
  validates :excused, inclusion: {in: [true, false]}

  # :attended | (:extended_loa | :excused) | (:awol | :absent)
  def status
    if attended
      :attended
    elsif excused
      if excused_by_extended_loa?
        :extended_loa
      else
        :excused
      end
    elsif event.mandatory
      :awol
    else
      :absent
    end
  end

  def awol?
    !attended && !excused
  end

  def excused_by_extended_loa?
    user.on_extended_loa?(event.datetime)
  end

  def self.dischargeable_dates(awols)
    unique_dates = awols.map { |awol| awol.event.starts_at.to_date }.uniq.sort

    dischargeable_dates = Set.new

    # For each unique date, check the remaining dates to see if they fall within
    # a 30-day period. If there are 3 or more, add them to the dischargeable dates set.
    (0..unique_dates.size - 3).each do |i|
      dates_within_period = unique_dates[i..]
        .take_while { |date| date - unique_dates[i] <= DISCHARGEABLE_PERIOD_DAYS }

      if dates_within_period.size >= 3
        dischargeable_dates.merge(dates_within_period)
      end
    end

    dischargeable_dates
  end
end
