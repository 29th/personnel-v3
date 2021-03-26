class ExtendedLOA < ApplicationRecord
  self.table_name = "eloas"
  audited
  belongs_to :user, foreign_key: "member_id"

  enum forum_id: {phpbb: "PHPBB",
                  smf: "SMF",
                  vanilla: "Vanilla",
                  discourse: "Discourse"}

  validates :user, presence: true
  validates :start_date, presence: true, timeliness: {type: :date}
  validates :end_date, presence: true, timeliness: {type: :date, after: :start_date}
  validates :return_date, timeliness: {type: :date, after: :start_date}, allow_blank: true
  validates :reason, presence: true
  validates :topic_id, numericality: {only_integer: true}, allow_nil: true

  before_create :set_posting_date

  scope :active, -> { where("start_date <= ? AND end_date >= ? AND (return_date IS NULL OR return_date >= ?)", Date.current, Date.current, Date.current) }

  private

  def set_posting_date
    self.posting_date = Time.zone.now
  end
end
