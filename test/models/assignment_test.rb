require "test_helper"

class AssignmentTest < ActiveSupport::TestCase
  test "active scope excludes assignments that ended in the past" do
    create_list(:assignment, 3)
    subject = create(:assignment, start_date: 1.week.ago, end_date: 1.day.ago)

    active_assignments = Assignment.active.all
    assert_equal 3, active_assignments.size
    refute_includes active_assignments, subject
  end

  test "active scope excludes assignments that ended today" do
    create_list(:assignment, 3)
    subject = create(:assignment, start_date: 1.week.ago, end_date: Date.current)

    active_assignments = Assignment.active.all
    assert_equal 3, active_assignments.size
    refute_includes active_assignments, subject
  end

  test "active scope excludes assignments that start in the future" do
    create_list(:assignment, 3)
    subject = create(:assignment, start_date: 1.week.from_now)

    active_assignments = Assignment.active.all
    assert_equal 3, active_assignments.size
    refute_includes active_assignments, subject
  end

  test "active scope allows passing a date" do
    create_list(:assignment, 3, start_date: 1.month.ago)
    inactive_subjects = [
      create(:assignment, start_date: 1.month.ago, end_date: 2.weeks.ago),
      create(:assignment, start_date: 1.month.ago, end_date: 1.week.ago),
      create(:assignment, start_date: 1.week.ago + 1.day)
    ]

    query_date = 1.week.ago
    active_assignments = Assignment.active(query_date).all
    assert_equal 3, active_assignments.size
    inactive_subjects.each do |subject|
      refute_includes active_assignments, subject
    end
  end
end
