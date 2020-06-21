require 'test_helper'

class AwardTest < ActiveSupport::TestCase
  test "valid by default" do
    award = create(:award)
    assert award.valid?
  end

  test "invalid without required fields" do
    required_fields = %i(code title game description image thumbnail bar)
    required_fields.each do |field|
      award = build(:award, field => nil)
      refute award.valid?
    end
  end

  test "invalid if url fields are not a url" do
    url_fields = %i[image thumbnail bar]
    url_fields.each do |field|
      award = build(:award, field => 'foo')
      refute award.valid?
    end
  end
end
