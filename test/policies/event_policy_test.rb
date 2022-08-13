require "test_helper"

class EventPolicyTest < ActiveSupport::TestCase
  test "user who's a member CAN show an event" do
    unit = create(:unit)
    user = create(:user)
    create(:assignment, user: user, unit: unit)

    event = build(:event)

    assert_permit user, event, :show
  end

  test "user who's not a member CANNOT show an event" do
    unit = create(:unit)
    user = create(:user)
    create(:assignment, user: user, unit: unit,
      start_date: 1.year.ago, end_date: 6.months.ago)

    event = build(:event)

    refute_permit user, event, :show
  end

  test "user with event_add_any CAN create/update/destroy an event" do
    unit = create(:unit)
    create(:permission, abbr: "event_add_any", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    event = build(:event)

    assert_permit user, event, :create
    assert_permit user, event, :update
    assert_permit user, event, :destroy
  end

  test "user with event_add on unit in scope CAN create/update/destroy its event" do
    unit = create(:unit)
    create(:permission, abbr: "event_add", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    event = build(:event, unit: unit)

    assert_permit user, event, :create
    assert_permit user, event, :update
    assert_permit user, event, :destroy
  end

  test "user with event_add on unit out of scope CANNOT create/update/destroy its event" do
    unit = create(:unit)
    create(:permission, abbr: "event_add", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    other_unit = create(:unit)
    event = build(:event, unit: other_unit)

    refute_permit user, event, :create
    refute_permit user, event, :update
    refute_permit user, event, :destroy
  end

  test "user with no event permission CANNOT show/create/update/destroy an event" do
    user = create(:user)
    event = build(:event)

    refute_permit user, event, :show
    refute_permit user, event, :create
    refute_permit user, event, :update
    refute_permit user, event, :destroy
  end

  test "user assigned to subtree unit CAN post loa" do
    platoon = create(:unit)
    squad = create(:unit, parent: platoon)
    user = create(:user)
    create(:assignment, user: user, unit: squad)
    event = create(:event, unit: squad)

    assert_permit user, event, :loa
  end

  test "user not assigned to subtree CANNOT post loa" do
    user = create(:user)
    unit = create(:unit)
    create(:assignment, user: user, unit: unit)
    other_unit = create(:unit)
    event = create(:event, unit: other_unit)

    refute_permit user, event, :loa
  end

  test "user CANNOT post loa for event that took place more than 1 day ago" do
    unit = create(:unit)
    user = create(:user)
    create(:assignment, user: user, unit: unit)
    event = create(:event, datetime: 2.days.ago, unit: unit)

    refute_permit user, event, :loa
  end

  test "user CAN edit aar for event that started before today" do
    unit = create(:unit)
    user = create(:user)
    create(:assignment, user: user, unit: unit)
    create(:permission, abbr: "event_aar", unit: unit)
    event = create(:event, datetime: 1.day.ago, unit: unit)

    assert_permit user, event, :aar
  end

  test "user CAN edit aar for event that starts later today" do
    unit = create(:unit)
    user = create(:user)
    create(:assignment, user: user, unit: unit)
    create(:permission, abbr: "event_aar", unit: unit)
    event = create(:event, datetime: 1.hour.from_now, unit: unit)

    assert_permit user, event, :aar
  end

  test "user CANNOT edit aar for event that starts after today" do
    unit = create(:unit)
    user = create(:user)
    create(:assignment, user: user, unit: unit)
    create(:permission, abbr: "event_aar", unit: unit)
    event = create(:event, datetime: 1.day.from_now, unit: unit)

    refute_permit user, event, :aar
  end
end
