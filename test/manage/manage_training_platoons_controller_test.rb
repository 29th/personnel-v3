require "test_helper"

module Manage
  class TrainingPlatoonsControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

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
        create(:permission, abbr: "manage", unit: @unit)
        @user = create(:user)
        create(:assignment, user: @user, unit: @unit)

        @awards = create_list(:award, 3)
        @rank = create(:rank)
        @position = create(:position, name: "Rifleman")

        sign_in_as @user
        clear_enqueued_jobs
      end

      test "unauthorized users cannot access or submit graduation form" do
        unauthorized_user = create(:user)
        unit = create(:unit)
        create(:permission, abbr: "manage", unit: unit) # but not admin
        create(:assignment, unit: unit, user: unauthorized_user)
        sign_in_as unauthorized_user

        get graduate_manage_training_platoon_path(@tp)
        assert_response :redirect

        assert_difference "Assignment.count", 0 do
          post graduate_manage_training_platoon_path(@tp), params: {
            forms_graduation: {
              assignments_attributes: assignments_attributes,
              award_ids: @awards.pluck(:id),
              rank_id: @rank.id,
              position_id: @position.id,
              topic_id: 0
            }
          }
        end
      end

      test "lists users with accepted enlistments" do
        get graduate_manage_training_platoon_path(@tp)

        @cadets.each do |cadet|
          assert_select ".forms_graduation_assignments_unit_id label", /#{cadet}/
        end
      end

      test "omits users whose enlistments are not accepted" do
        denied_enl = create(:enlistment, status: :denied, unit: @tp)
        withdrawn_enl = create(:enlistment, status: :withdrawn, unit: @tp)

        get graduate_manage_training_platoon_path(@tp)

        assert_select ".forms_graduation_assignments_unit_id label", text: /#{denied_enl.user}/, count: 0
        assert_select ".forms_graduation_assignments_unit_id label", text: /#{withdrawn_enl.user}/, count: 0
      end

      test "lists user timezone and recruiter unit" do
        get graduate_manage_training_platoon_path(@tp)

        assert_select ".forms_graduation_assignments_unit_id small", /PST/
        assert_select ".forms_graduation_assignments_unit_id small", /S1/
      end

      test "unit selection only lists squads" do
        create(:unit, name: "Second Squad", abbr: "S2")
        create(:unit, name: "First Platoon", abbr: "P1")

        get graduate_manage_training_platoon_path(@tp)

        assert_select ".forms_graduation_assignments_unit_id:last select option", {text: /S1/, count: 1}
        assert_select ".forms_graduation_assignments_unit_id:last select option", {text: /S2/, count: 1}
        assert_select ".forms_graduation_assignments_unit_id:last select option", {text: /P1/, count: 0}
      end

      test "unit selection includes number of active members" do
        create(:unit, name: "Second Squad", abbr: "S2")
        create(:assignment, unit: @squad, end_date: 1.day.ago)

        get graduate_manage_training_platoon_path(@tp)

        assert_select ".forms_graduation_assignments_unit_id:last select option", /S1 \(1\)/
        assert_select ".forms_graduation_assignments_unit_id:last select option", /S2 \(0\)/
      end

      test "redirected to training platoon on success" do
        assert_enqueued_jobs @cadets.size, only: UpdateDiscourseDisplayNameJob do
          assert_enqueued_jobs @cadets.size, only: UpdateDiscourseRolesJob do
            assert_enqueued_jobs @cadets.size, only: GenerateServiceCoatJob do
              assert_difference "Assignment.count", @cadets.size do
                # assert_difference -> { Assignment.count } => @cadets.size, -> { Promotion.count } => @cadets.size do
                post graduate_manage_training_platoon_path(@tp), params: {
                  forms_graduation: {
                    assignments_attributes: assignments_attributes,
                    award_ids: @awards.pluck(:id),  # .prepend(""),
                    rank_id: @rank.id,
                    position_id: @position.id,
                    topic_id: 0
                  }
                }
              end
            end
          end
        end

        assert_redirected_to manage_training_platoon_path(@tp)
      end

      test "re-renders previously selected form values when displaying validation errors" do
        assert_no_difference "Assignment.count" do
          post graduate_manage_training_platoon_path(@tp), params: {
            forms_graduation: {
              assignments_attributes: assignments_attributes,
              award_ids: @awards.pluck(:id).prepend(""),
              rank_id: @rank.id,
              position_id: "",
              topic_id: 0
            }
          }
        end

        assert_select ".forms_graduation_assignments_unit_id select option[selected]", /#{@squad.abbr}/
        assert_select "#forms_graduation_rank_id option[selected]", @rank.name
      end

      private

      def assignments_attributes
        @cadets.each_with_index.each_with_object({}) do |(cadet, index), accum|
          accum[index.to_s] = {"member_id" => cadet.id, "unit_id" => @squad.id}
        end
      end
    end
  end
end
