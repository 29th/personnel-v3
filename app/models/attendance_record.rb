class AttendanceRecord < ApplicationRecord
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
end
