class BanLog < ApplicationRecord
  self.table_name = "banlog"
  audited

  belongs_to :admin, class_name: "User", foreign_key: "id_admin"
  belongs_to :poster, class_name: "User", foreign_key: "id_poster"

  validates :date, presence: true
  validates_date :date
  validates :roid, presence: true, numericality: {only_integer: true}
  validates :handle, length: {maximum: 32}
  validates :ip, length: {maximum: 20}
  validates :admin, presence: true
  validates :poster, presence: true
  validates :reason, length: {maximum: 1000}
end
