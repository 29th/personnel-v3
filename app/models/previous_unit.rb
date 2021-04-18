# for Enlistments
class PreviousUnit
  include ActiveModel::Model

  attr_accessor :unit, :game, :name, :rank, :reason

  validates :unit, presence: true, length: {maximum: 60}
  validates :game, length: {maximum: 60}
  validates :name, length: {maximum: 60}
  validates :rank, length: {maximum: 60}
  validates :reason, presence: true, length: {maximum: 128}

  def as_json(options = {})
    # Don't store validation properties in database
    super(options).except("validation_context", "errors")
  end
end
