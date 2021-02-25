require 'test_helper'

class AwardTest < ActiveSupport::TestCase
  test "valid by default" do
    award = create(:award)
    assert award.valid?
  end

  test "invalid without required fields" do
    required_fields = %i(code title game description)
    required_fields.each do |field|
      award = build(:award, field => nil)
      refute award.valid?
    end
  end
end
