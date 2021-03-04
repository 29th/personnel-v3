require 'test_helper'

class UnitTest < ActiveSupport::TestCase
  test "invalid without required fields" do
    required_fields = %i(name abbr classification)
    required_fields.each do |field|
      unit = build(:unit, field => nil)
      refute unit.valid?
    end
  end

  test "abbr cannot be longer than 8 chars" do
    unit = build(:unit, abbr: Faker::String.random(length: 9))
    refute unit.valid?
  end

  test "slogan cannot be longer than 140 chars" do
    unit = build(:unit, slogan: Faker::String.random(length: 141))
    refute unit.valid?
  end
end
