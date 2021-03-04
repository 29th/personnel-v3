class Country < ApplicationRecord
  validates :abbr, presence: true, length: { maximum: 2 },
                   format: { with: /\A[A-Z]+\Z/ }
  validates :name, presence: true

  default_scope -> { order(:name) }

  def sym
    abbr.downcase.to_sym
  end
end
