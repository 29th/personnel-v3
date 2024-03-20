require "test_helper"

class Forms::GraduationTest < ActiveSupport::TestCase
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

    @cadets_attributes = @cadets.each_with_index.reduce({}) do |accum, (cadet, index)|
      accum[index] = {"id" => cadet.id, "unit_id" => @squads[index]}
    end

    @awards = create_list(:award, 2)
    @rank = create(:rank)
    @position = create(:position, name: "Rifleman")

    User.any_instance.stubs(:update_forum_display_name).returns(true)
    User.any_instance.stubs(:update_forum_roles).returns(true)
    User.any_instance.stubs(:update_coat).returns(true)
  end

  test "save rolls back if any cadet fails" do
    modified_cadets_attributes = @cadets_attributes.dup
    modified_cadets_attributes.last["unit_id"] = 999999
    graduation = Forms::Graduation.new(unit: @tp, cadets_attributes: modified_cadets_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id)

    assert_no_difference ["Assignment.count", "Promotion.count", "Award.count"] do
      refute graduation.save
    end

    @cadets.reload
    @cadets.each do |cadet|
      assert_equal "Rec.", cadet.rank.abbr
    end
  end

  test "save rolls back if unit updates fail" do
    graduation = Forms::Graduation.new(unit: @tp, cadets_attributes: @cadets_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id)

    Unit.any_instance.stub(:update!).raises(ActiveRecord::ActiveRecordError)

    assert_no_difference ["Assignment.count", "Promotion.count", "Award.count"] do
      refute graduation.save
    end
  end

  test "does not allow graduating a user who is not part of the training platoon" do
    non_member = create(:user)
    modified_cadets_attributes = @cadets_attributes.dup
    modified_cadets_attributes["999"] = {"id" => non_member.id, "unit_id" => @squads.first.id}
    graduation = Forms::Graduation.new(unit: @tp, cadets_attributes: modified_cadets_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id)

    assert graduate.save

    assert_nil non_member.assignments
    assert_nil non_member.promotions
    assert_nil non_member.awards
  end

  test "validates presence of all attributes before saving" do
    skip
  end

  test "creates all awards, assignment, promotion records and updates user rank" do
    graduation = Forms::Graduation.new(unit: @tp, cadets_attributes: @cadets_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id)

    assert graduation.save

    @cadets.reload
    @cadets.each do |cadet, index|
      assert_equal @awards.size, cadet.awards
      assert_equal 1, cadet.assignments.active.size
      assert_equal @squads[index], cadet.assignments.active.first.unit
      assert_equal 1, cadet.promotions.size
      assert_equal @rank, cadet.rank
    end
  end

  test "queues update_* background jobs" do
    graduation = Forms::Graduation.new(unit: @tp, cadets_attributes: @cadets_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id)

    User.any_instance.expects(:update_forum_display_name)
    User.any_instance.expects(:update_forum_roles)
    User.any_instance.expects(:update_coat)

    assert graduation.save
  end

  test "does not allow graduating a user who is already graduated" do
    graduated_user = create(:user, rank_abbr: "PFC")
    create(:enlistment, status: :accepted, unit: @tp, user: graduated_user)
    create(:assignment, unit: @tp, user: graduated_user,
      start_date: 2.weeks.ago, end_date: 1.week.ago)
    create(:assignment, user: graduated_user, unit: @squads.first)

    modified_cadets_attributes = @cadets_attributes.dup
    modified_cadets_attributes["999"] = {"id" => graduated_user.id, "unit_id" => @squads.last.id}

    graduation = Forms::Graduation.new(unit: @tp, cadets_attributes: modified_cadets_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id)

    assert graduation.save

    graduated_user.reload
    assert_equal 1, graduated_user.assignments.active
    assert_equal @squads.first, graduated_user.assignments.active.first
    assert_equal "PFC", graduated_user.rank.abbr
  end

  test "does not allow graduating a user whose enlistment is not accepted" do
    denied_user = create(:user)
    create(:enlistment, status: :denied, unit: @tp, user: denied_user)
    create(:assignment, position: "Recruit", unit: @tp, user: denied_user,
      start_date: 2.days.ago, end_date: 1.day.ago)

    modified_cadets_attributes = @cadets_attributes.dup
    modified_cadets_attributes["999"] = {"id" => graduated_user.id, "unit_id" => @squads.last.id}

    graduation = Forms::Graduation.new(unit: @tp, cadets_attributes: modified_cadets_attributes,
      award_ids: @awards.pluck(:id), rank_id: @rank.id, position_id: @position.id)

    assert graduation.save

    denied_user.reload
    assert_nil denied_user.assignments.active
    refute_equal @rank, denied_user.rank
  end

  test "creates forum topic" do
    skip
  end
end
