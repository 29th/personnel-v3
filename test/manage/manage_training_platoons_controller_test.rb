require "test_helper"

class Mange::TrainingPlatoonsControllerTest < ActionDispatch::IntegrationTest
  class Graduation < Manage::TrainingPlatoonsControllerTest
    setup do
      @tp = create(:unit, classification: :training)

      recruiter = create(:user)
      @squad = create(:unit, name: "First Squad", abbr: "S1")
      create(:assignment, user: recruiter, unit: @squad)

      @cadets = create_list(:user, 5, rank_abbr: "Rec.")
      @cadets.each do |cadet|
        create(:enlistment, status: :accepted, unit: @tp, user: cadet,
          timezone: :pst, recruiter_user: recruiter)
        create(:assignment, unit: @tp, user: cadet)
      end

      @unit = create(:unit)
      create(:permission, abbr: "admin", unit: @unit)
      @user = create(:user)
      create(:assignment, user: @user, unit: @unit)

      @awards = create_list(:award, 3)
      @rank = create(:rank)
      @position = create(:position, name: "Rifleman")

      sign_in_as @user
    end

    test "lists users with accepted enlistments" do
      get graduate_manage_training_platoon_path(@tp)

      @cadets.each do |cadet|
        assert_select ".forms_graduation_cadets_unit_id label", /#{cadet}/
      end
    end

    test "omits users whose enlistments are not accepted" do
      denied_enl = create(:enlistment, status: :denied, unit: @tp)
      withdrawn_enl = create(:enlistment, status: :withdrawn, unit: @tp)

      get graduate_manage_training_platoon_path(@tp)

      refute_select ".forms_graduation_cadets_unit_id label", /#{denied_enl.user}/
      refute_select ".forms_graduation_cadets_unit_id label", /#{withdrawn_enl.user}/
    end

    test "lists user timezone and recruiter unit" do
      get graduate_manage_training_platoon_path(@tp)

      assert_select ".forms_graduation_cadets_unit_id small", /PST/
      assert_select ".forms_graduation_cadets_unit_id small", /S1/
    end

    test "unit selection only lists squads" do
      create(:unit, name: "Second Squad", abbr: "S2")
      create(:unit, name: "First Platoon", abbr: "P1")

      get graduate_manage_training_platoon_path(@tp)

      assert_select ".forms_graduation_cadets_unit_id select option", /S1/
      assert_select ".forms_graduation_cadets_unit_id select option", /S2/
      refute_select ".forms_graduation_cadets_unit_id select option", /P1/
    end

    test "unit selection includes unit size" do
      create(:unit, name: "Second Squad", abbr: "S2")

      get graduate_manage_training_platoon_path(@tp)

      assert_select ".forms_graduation_cadets_unit_id select option", /S1 (1)/
      assert_select ".forms_graduation_cadets_unit_id select option", /S2 (0)/
    end

    test "redirected to training platoon on success" do
      assert_difference ["Assignment.count", "Promotion.count"], @cadets.size do
        post graduate_manage_training_platoon_path(@tp), params: {
          forms_graduation: {
            cadets_attributes: modified_cadets_attributes,
            award_ids: @awards.pluck(:id).prepend(""),
            rank_id: @rank.id,
            position_id: @position.id
          }
        }
      end

      assert_redirected_to manage_training_platoon_path(@tp)
    end

    test "throws validation error if any user assignment is omitted" do
      modified_cadets_attributes = cadets_attributes.dup
      modified_cadets_attributes.last["unit_id"] = ""

      assert_no_difference "Assignment.count" do
        post graduate_manage_training_platoon_path(@tp), params: {
          forms_graduation: {
            cadets_attributes: modified_cadets_attributes,
            award_ids: @awards.pluck(:id).prepend(""),
            rank_id: @rank.id,
            position_id: @position.id
          }
        }
      end

      assert_select "#page_title", "Graduate"
    end

    test "re-renders previously selected form values when displaying validation errors" do
      assert_no_difference "Assignment.count" do
        post graduate_manage_training_platoon_path(@tp), params: {
          forms_graduation: {
            cadets_attributes: cadets_attributes,
            award_ids: @awards.pluck(:id).prepend(""),
            rank_id: @rank.id,
            position_id: ""
          }
        }
      end

      assert_select ".forms_graduation_cadets_unit_id select option:selected", /#{@squad.abbr}/
      assert_select "#forms_graduation_rank_id option:selected", @rank.name
      assert_select "#forms_graduation_position_id option:selected", @position.name
    end

    private

    def cadets_attributes
      @cadets.each_with_index.reduce({}) do |accum, (cadet, index)|
        accum[index.to_s] = {"id" => cadet.id, "unit_id" => @squad.id}
      end
    end
  end
end
