require "test_helper"

class UserAwardTest < ActiveSupport::TestCase
  test "valid by default" do
    user_award = create(:user_award)
    assert user_award.valid?
  end

  test "invalid without required fields" do
    required_fields = %i[user award date]
    required_fields.each do |field|
      user_award = build(:user_award, field => nil)
      refute user_award.valid?
    end
  end

  test "invalid with non-numeric topic id" do
    user_award = build(:user_award, topic_id: "foo")
    refute user_award.valid?
  end

  test "invalid with bad date" do
    user_award = build(:user_award, date: "yesterday")
    refute user_award.valid?
  end
end
