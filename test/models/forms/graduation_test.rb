require "test_helper"

class Forms::GraduationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @tp = create(:unit, classification: :training)

    @cadets = create_list(:user, 5, rank_abbr: "Rec.")
    @cadets.each do |cadet|
      create(:enlistment, status: :accepted, unit: @tp, user: cadet)
      create(:assignment, unit: @tp, user: cadet)
    end

    @squads = create_list(:unit, 5, name: "Squad") do |unit, index|
      unit.name = "Squad #{index + 1}"
    end

    @assignments_attributes = @cadets.each_with_index.each_with_object({}) do |(cadet, index), accum|
      accum[index.to_s] = {"member_id" => cadet.id.to_s, "unit_id" => @squads[index].id.to_s}
    end

    @awards = create_list(:award, 2)
    @rank = create(:rank)
    @position = create(:position, name: "Rifleman")

    clear_enqueued_jobs
  end

  test "save rolls back if unit updates fail" do
    graduation = Forms::Graduation.new(training_platoon: @tp, assignments_attributes: @assignments_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id,
      topic_id: 0)

    Unit.any_instance.stubs(:update!).raises(ActiveRecord::RecordInvalid)

    assert_no_difference ["Assignment.count", "Promotion.count", "Award.count"] do
      refute graduation.save
    end
  end

  test "validates presence of all attributes" do
    graduation_without_unit = Forms::Graduation.new(assignments_attributes: @assignments_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id,
      topic_id: 0)
    graduation_without_awards = Forms::Graduation.new(training_platoon: @tp,
      assignments_attributes: @assignments_attributes,
      rank_id: @rank.id, position_id: @position.id, topic_id: 0)
    graduation_without_rank = Forms::Graduation.new(training_platoon: @tp,
      assignments_attributes: @assignments_attributes,
      award_ids: @awards.pluck(:id), position_id: @position.id, topic_id: 0)
    graduation_without_position = Forms::Graduation.new(training_platoon: @tp,
      assignments_attributes: @assignments_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, topic_id: 0)

    refute graduation_without_unit.valid?, "unit should be required"
    refute graduation_without_awards.valid?, "awards should be required"
    refute graduation_without_rank.valid?, "rank should be required"
    refute graduation_without_position.valid?, "position should be required"

    refute graduation_without_unit.save, "didn't validate before saving"
  end

  test "creates all awards, assignment, promotion records and updates user rank" do
    graduation = Forms::Graduation.new(training_platoon: @tp, assignments_attributes: @assignments_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id,
      topic_id: 0)

    assert graduation.save

    @cadets.each_with_index do |cadet, index|
      cadet.reload
      assert_equal @awards.size, cadet.user_awards.size
      assert_equal 1, cadet.assignments.active.size
      assert_equal @squads[index], cadet.assignments.active.first.unit
      assert_equal 1, cadet.promotions.size
      assert_equal @rank, cadet.rank
    end
  end

  test "does not create any records for users with no assignment set" do
    modified_assignments_attributes = @assignments_attributes.dup
    last_key = modified_assignments_attributes.keys.last
    modified_assignments_attributes[last_key]["unit_id"] = ""
    washout_user_id = modified_assignments_attributes[last_key]["member_id"]
    graduation = Forms::Graduation.new(training_platoon: @tp, assignments_attributes: modified_assignments_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id,
      topic_id: 0)

    assert graduation.save

    washout = User.find(washout_user_id)
    assert_empty washout.promotions
    assert_empty washout.user_awards
    refute_equal @rank, washout.rank
  end

  test "queues update_* background jobs" do
    graduation = Forms::Graduation.new(training_platoon: @tp, assignments_attributes: @assignments_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id,
      topic_id: 0)

    assert_enqueued_jobs @cadets.size, only: UpdateDiscourseDisplayNameJob do
      assert_enqueued_jobs @cadets.size, only: UpdateDiscourseRolesJob do
        assert_enqueued_jobs @cadets.size, only: GenerateServiceCoatJob do
          assert graduation.save
        end
      end
    end
  end

  test "does not allow graduating a user who is not part of the training platoon" do
    non_member = create(:user)
    modified_assignments_attributes = @assignments_attributes.dup
    modified_assignments_attributes["999"] = {"member_id" => non_member.id, "unit_id" => @squads.first.id}
    graduation = Forms::Graduation.new(training_platoon: @tp, assignments_attributes: modified_assignments_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id,
      topic_id: 0)

    exception = assert_raises Forms::Graduation::IneligibleCadet do
      graduation.save
    end

    assert_match(/#{non_member}/, exception.message)
    assert_empty non_member.assignments, "user should have no assignments"
    assert_empty non_member.promotions, "user should have no promotions"
    assert_empty non_member.user_awards, "user should have no user_awards"
  end

  test "does not allow graduating a user who is already graduated" do
    already_graduated_user = create(:user, rank_abbr: "PFC")
    create(:enlistment, status: :accepted, unit: @tp, user: already_graduated_user)
    create(:assignment, unit: @tp, user: already_graduated_user,
      start_date: 2.weeks.ago, end_date: 1.week.ago)
    create(:assignment, user: already_graduated_user, unit: @squads.first)

    modified_assignments_attributes = @assignments_attributes.dup
    modified_assignments_attributes["999"] = {"member_id" => already_graduated_user.id, "unit_id" => @squads.last.id}

    graduation = Forms::Graduation.new(training_platoon: @tp, assignments_attributes: modified_assignments_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id,
      topic_id: 0)

    assert_raises Forms::Graduation::IneligibleCadet do
      graduation.save
    end

    already_graduated_user.reload
    assert_equal 1, already_graduated_user.assignments.active.size, "already graduated user should only have 1 active assignment"
    assert_equal @squads.first, already_graduated_user.assignments.active.first.unit, "already graduated user's assignment shouldn't change"
    assert_equal "PFC", already_graduated_user.rank.abbr, "already graduated user's rank shouldn't change"
  end

  test "does not allow graduating a user whose enlistment is not accepted" do
    denied_user = create(:user)
    create(:enlistment, status: :denied, unit: @tp, user: denied_user)
    create(:assignment, unit: @tp, user: denied_user, start_date: 2.days.ago,
      end_date: 1.day.ago)

    modified_assignments_attributes = @assignments_attributes.dup
    modified_assignments_attributes["999"] = {"member_id" => denied_user.id, "unit_id" => @squads.last.id}

    graduation = Forms::Graduation.new(training_platoon: @tp, assignments_attributes: modified_assignments_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id,
      topic_id: 0)

    assert_raises Forms::Graduation::IneligibleCadet do
      graduation.save
    end

    denied_user.reload
    assert_empty denied_user.assignments.active, "denied user should have no active assignments"
    refute_equal @rank, denied_user.rank, "denied user's rank should not change"
  end

  test "creates forum topic" do
    skip
  end
end
