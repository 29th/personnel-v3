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

  class ArraySerializer
    def self.load(value)
      json = ActiveRecord::Coders::JSON.load(value)
      json&.map { |hash| PreviousUnit.new(hash) } || []
    end

    def self.dump(models)
      ActiveRecord::Coders::JSON.dump(models) unless models.empty?
    end
  end
end
