require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "invalid without required fields" do
    required_fields = %i[type datetime unit server]
    required_fields.each do |field|
      event = build(:event, field => nil)
      refute event.valid?, "#{field} is not required"
    end
  end

  test "expected_users includes subtree users" do
    platoon = create(:unit)
    create(:assignment, unit: platoon)
    squad = create(:unit, parent: platoon)
    user = create(:user)
    create(:assignment, user: user, unit: squad)
    event = create(:event, unit: platoon)

    expected_users = event.expected_users

    assert_equal 2, expected_users.size
    assert_includes expected_users, user
  end

  test "expected_users excludes users assigned after the event" do
    unit = create(:unit)
    event = create(:event, datetime: 2.weeks.ago, unit: unit)
    create_list(:assignment, 3, start_date: 4.weeks.ago, unit: unit)
    new_user = create(:user)
    create(:assignment, start_date: 1.week.ago, user: new_user, unit: unit)

    expected_users = event.expected_users

    assert_equal 3, expected_users.size
    refute_includes expected_users, new_user
  end

  test "expected_users excludes users whose assignment ended before the event" do
    unit = create(:unit)
    event = create(:event, datetime: 2.weeks.ago, unit: unit)
    create_list(:assignment, 3, start_date: 4.weeks.ago, unit: unit)
    new_user = create(:user)
    create(:assignment, start_date: 4.weeks.ago, end_date: 3.weeks.ago,
      user: new_user, unit: unit)

    expected_users = event.expected_users

    assert_equal 3, expected_users.size
    refute_includes expected_users, new_user
  end

  test "expected_users includes users whose assignment has since ended" do
    unit = create(:unit)
    event = create(:event, datetime: 2.weeks.ago, unit: unit)
    create_list(:assignment, 3, start_date: 4.weeks.ago, unit: unit)
    subject_user = create(:user)
    create(:assignment, start_date: 4.week.ago, end_date: 1.week.ago, user: subject_user, unit: unit)

    expected_users = event.expected_users

    assert_equal 4, expected_users.size
    assert_includes expected_users, subject_user
  end

  # e.g. training platoons
  test "expected_users works even if unit is inactive" do
    unit = create(:unit, active: false)
    event = create(:event, datetime: 2.weeks.ago, unit: unit)
    create_list(:assignment, 3, start_date: 3.weeks.ago, end_date: 1.week.ago, unit: unit)

    expected_users = event.expected_users

    assert_equal 3, expected_users.size
  end
end
