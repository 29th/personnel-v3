class AttendanceRecord < ApplicationRecord
  self.table_name = "attendance"
  audited
  belongs_to :user, foreign_key: "member_id"
  belongs_to :event

  validates :attended, inclusion: {in: [true, false]}, allow_nil: true
  validates :excused, inclusion: {in: [true, false]}

  def awol?
    !attended && !excused
  end

  def excused_by_extended_loa?
    user.on_extended_loa?(event.datetime)
  end
end
