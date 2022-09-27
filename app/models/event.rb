class Event < ApplicationRecord
  self.inheritance_column = nil # don't treat type field as STI
  audited
  belongs_to :unit
  belongs_to :server
  belongs_to :reporter, foreign_key: "reporter_member_id", class_name: "User", optional: true
  has_many :attendance_records, -> { includes(user: :rank).order("ranks.order DESC", "members.last_name") } do
    def find_by_user(user)
      find_by(member_id: user.id)
    end
  end
  has_many :users, through: :attendance_records

  scope :by_user, ->(user) do
    unit_ids = user.active_assignment_unit_path_ids
    where(unit: unit_ids)
  end

  attr_accessor :bulk_dates
  attr_accessor :time
  attr_writer :starts_at_local

  TYPES = ["Squad Drills", "Platoon Drills", "Company Drills", "Battalion Drills", "Basic Combat Training",
    "Public Scrimmage", "Special Event"]
  validates :type, presence: true, inclusion: {in: TYPES}

  TIMEZONES = [
    "Pacific Time (US & Canada)",
    "Eastern Time (US & Canada)",
    "UTC",
    "London"
  ]
  validates :time_zone, inclusion: {in: TIMEZONES}

  validates :starts_at, presence: true
  validates_datetime :starts_at
  validates :mandatory, inclusion: {in: [true, false]}
  validates :server, presence: true

  before_save :update_report_dates,
    if: proc { attendance_records.any? || will_save_change_to_report? }
  before_save :update_legacy_datetime

  self.skip_time_zone_conversion_for_attributes = [:datetime, :report_posting_date, :report_edit_date]

  def expected_users
    unit.subtree_users.active(starts_at).includes(:rank)
  end

  def extended_loas
    ExtendedLOA.active(starts_at)
      .where(member_id: expected_users.ids)
  end

  def title
    if unit
      "#{unit.subtree_abbr} #{type}"
    else
      type
    end
  end

  # Alias for simple_calendar
  def start_time
    starts_at
  end

  def update_attendance(attended_user_ids)
    attendance = expected_users.ids.collect do |user_id|
      {event_id: id, member_id: user_id,
       attended: attended_user_ids.include?(user_id)}
    end

    AttendanceRecord.upsert_all(attendance) if expected_users.any?
  end

  def excuse_users_on_extended_loa
    attendance = extended_loas.collect do |eloa|
      {event_id: id, member_id: eloa.user.id, excused: true}
    end

    AttendanceRecord.upsert_all(attendance) if extended_loas.any?
  end

  def posted_loa?(user)
    attendance_record = attendance_records.find_by_user(user)
    attendance_record&.excused
  end

  def post_loa(user)
    AttendanceRecord.upsert({event_id: id, member_id: user.id, excused: true})
  end

  def cancel_loa(user)
    attendance_record = attendance_records.find_by_user(user)
    if attendance_record.attended.nil?
      attendance_record.destroy
    else
      attendance_record.update(excused: false)
    end
  end

  def starts_at_local
    @starts_at_local ||= starts_at&.in_time_zone(time_zone)
  end

  def aar_posted?
    report_posting_date.present?
  end

  private

  def update_report_dates
    self.report_posting_date ||= Time.current
    self.report_edit_date = Time.current
  end

  # Personnel v2 uses the `datetime` column, which is stored in Eastern Time
  def update_legacy_datetime
    # Remove time zone so rails doesn't try to convert it
    self.datetime = starts_at.in_time_zone("Eastern Time (US & Canada)")
      .strftime("%F %R")
  end
end
