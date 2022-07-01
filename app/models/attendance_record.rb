class AttendanceRecord < ApplicationRecord
  self.table_name = "attendance"
  audited
  belongs_to :user, foreign_key: "member_id"
  belongs_to :event

  validates :attended, inclusion: {in: [true, false]}
  validates :excused, inclusion: {in: [true, false]}

  def awol?
    !attended && !excused
  end
end
