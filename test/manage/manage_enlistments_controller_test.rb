require "test_helper"

module Manage
  class EnlistmentsControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    test "user cannot process enlistment without permission" do
      stub_request(:any, /#{Settings.discourse.base_url.internal}.*/)

      unit = create(:unit)
      create(:permission, abbr: "manage", unit: unit)
      user = create(:user)
      create(:assignment, user: user, unit: unit)
      sign_in_as user
      enlistment = create(:enlistment)

      get process_enlistment_manage_enlistment_url(enlistment)
      assert_redirected_to root_url
      assert_match(/not authorized/, flash[:alert])

      patch process_enlistment_manage_enlistment_url(enlistment)
      assert_redirected_to root_url
      assert_match(/not authorized/, flash[:alert])
    end

    class AnalyzeEnlistmentTest < Manage::EnlistmentsControllerTest
      setup do
        @unit = create(:unit)
        @user = create(:user, last_name: "Golf")
        create(:assignment, user: @user, unit: @unit)
        sign_in_as @user
        create(:permission, abbr: "manage", unit: @unit)
        @disocurse_url = Settings.discourse.base_url.internal
      end

      test "links user with same steam id as enlistment field" do
        create(:permission, abbr: "enlistment_edit_any", unit: @unit)
        stub_request(:any, /#{@discourse_url}.*/).to_return(status: 404)

        steam_id = "12345678912345678"
        enlistment = create(:enlistment)
        enlistment.update_columns(steam_id: steam_id) # bypass before_save callback
        _other_user = create(:user, steam_id: steam_id, last_name: "Matchee")

        get manage_enlistment_url(enlistment)

        assert_select "#linked-users-by-steam-id", /Matchee/
      end

      test "links user with same steam id as enlistment user" do
        create(:permission, abbr: "enlistment_edit_any", unit: @unit)
        stub_request(:any, /#{@discourse_url}.*/).to_return(status: 404)

        steam_id = "12345678912345678"
        user = create(:user, steam_id: steam_id)
        enlistment = create(:enlistment, user: user)
        enlistment.update_columns(steam_id: "9999") # bypass before_save callback
        _other_user = create(:user, steam_id: steam_id, last_name: "Matchee")

        get manage_enlistment_url(enlistment)

        assert_select "#linked-users-by-steam-id", /Matchee/
      end

      test "links users with similar last names" do
        create(:permission, abbr: "enlistment_edit_any", unit: @unit)
        stub_request(:any, /#{@discourse_url}.*/).to_return(status: 404)

        user = create(:user, last_name: "Anders", first_name: "Subject")
        enlistment = create(:enlistment, user: user)
        create(:user, last_name: "Anders", first_name: "Another")
        create(:user, last_name: "Anderson")
        create(:user, last_name: "AnDers")
        create(:user, last_name: "Somethingelse")

        get manage_enlistment_url(enlistment)

        assert_select "#users-with-matching-name a", {text: /Another/, count: 1}
        assert_select "#users-with-matching-name a", {text: /Anderson/, count: 1}
        assert_select "#users-with-matching-name a", {text: /AnDers/, count: 1}
        assert_select "#users-with-matching-name a", {text: /Somethingelse/, count: 0}
        assert_select "#users-with-matching-name a", {text: /Subject/, count: 0}
      end
    end

    class EditEnlistmentTest < Manage::EnlistmentsControllerTest
      setup do
        stub_request(:any, /#{Settings.discourse.base_url.internal}.*/)

        unit = create(:unit)
        create(:permission, abbr: "manage", unit: unit)
        create(:permission, abbr: "enlistment_edit_any", unit: unit)
        create(:position, name: "Recruit")

        @user = create(:user)
        create(:assignment, user: @user, unit: unit)
        sign_in_as @user
        clear_enqueued_jobs
      end

      test "copies user attributes to legacy enlistment fields when updated" do
        enlistment = create(:enlistment)
        uk = create(:country, name: "UK")

        patch manage_enlistment_url(enlistment), params: {
          enlistment: {
            user_attributes: {
              last_name: "Zulu",
              country_id: uk.id,
              steam_id: "7777"
            }
          }
        }

        enlistment.reload
        assert_equal "Zulu", enlistment.last_name
        assert_equal "7777", enlistment.steam_id
        assert_equal "UK", enlistment.country.name
      end

      test "changing last_name of accepted enlistment updates forum display name" do
        enlistment = create(:enlistment, status: :accepted)

        assert_enqueued_with(job: UpdateDiscourseDisplayNameJob, args: [enlistment.user]) do
          patch manage_enlistment_url(enlistment), params: {
            enlistment: {
              user_attributes: {
                last_name: "Zulu"
              }
            }
          }
        end
      end
    end

    class ProcessEnlistmentTest < Manage::EnlistmentsControllerTest
      setup do
        stub_request(:any, /#{Settings.discourse.base_url.internal}.*/)

        unit = create(:unit)
        create(:permission, abbr: "manage", unit: unit)
        create(:permission, abbr: "enlistment_process_any", unit: unit)
        create(:position, name: "Recruit")

        @user = create(:user)
        create(:assignment, user: @user, unit: unit)
        sign_in_as @user
        clear_enqueued_jobs
      end

      test "creates assignment when status set to accepted and unit set" do
        enlistment = create(:enlistment)
        tp = create(:unit, classification: :training)

        assert_difference("Assignment.count", 1) do
          patch process_enlistment_manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: tp.id,
              status: "accepted"
            }
          }
        end
        assert_redirected_to manage_enlistment_url(enlistment)

        created_assignment = Assignment.last
        assert_equal enlistment.user, created_assignment.user
        assert_equal tp, created_assignment.unit
        assert_equal Date.current, created_assignment.start_date
      end

      test "creates assignment when status set to accepted and unit already set" do
        tp = create(:unit, classification: :training)
        enlistment = create(:enlistment, unit: tp)

        assert_difference("Assignment.count", 1) do
          patch process_enlistment_manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: tp.id,
              status: "accepted"
            }
          }
        end
        assert_redirected_to manage_enlistment_url(enlistment)

        created_assignment = Assignment.last
        assert_equal enlistment.user, created_assignment.user
        assert_equal tp, created_assignment.unit
        assert_equal Date.current, created_assignment.start_date
      end

      test "does not create assignment if unit set but status not set to accepted" do
        enlistment = create(:enlistment)
        tp = create(:unit, classification: :training)

        assert_difference("Assignment.count", 0) do
          patch process_enlistment_manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: tp.id,
              status: "pending"
            }
          }
        end
        assert_redirected_to manage_enlistment_url(enlistment)
      end

      test "changes assignment when already accepted and unit changed" do
        old_tp = create(:unit, classification: :training)
        enlistment = create(:enlistment, unit: old_tp, status: :accepted)
        create(:assignment, user: enlistment.user, unit: old_tp)
        new_tp = create(:unit, classification: :training)

        assert_difference("Assignment.count", 0) do
          patch process_enlistment_manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: new_tp.id,
              status: "accepted"
            }
          }
        end

        assignments = enlistment.user.assignments.active.training
        assert_equal 1, assignments.length
        assert_equal new_tp, assignments[0].unit
      end

      ["pending", "denied", "withdrawn"].each do |status|
        test "destroys assignment when status set to #{status} and already assigned" do
          tp = create(:unit, classification: :training)
          enlistment = create(:enlistment, unit: tp, status: :accepted)
          create(:assignment, user: enlistment.user, unit: tp)

          assert_difference("Assignment.count", -1) do
            patch process_enlistment_manage_enlistment_url(enlistment), params: {
              enlistment: {
                unit_id: tp.id,
                status: status
              }
            }
          end

          enlistment.user.assignments.reload
          assert enlistment.user.assignments.empty?
        end
      end

      test "ends assignment when status set to awol and already assigned" do
        tp = create(:unit, classification: :training)
        enlistment = create(:enlistment, unit: tp, status: :accepted)
        create(:assignment, user: enlistment.user, unit: tp)

        assert_difference("Assignment.count", 0) do
          patch process_enlistment_manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: tp.id,
              status: "awol"
            }
          }
        end

        assignments = enlistment.user.assignments.training
        assert_equal 1, assignments.length
        assert_equal Date.current, assignments[0].end_date
      end

      test "does not allow changes to enlistments from more than 3 months ago" do
        tp = create(:unit, classification: :training)
        enlistment = create(:enlistment, unit: tp, status: :accepted, date: 4.months.ago)
        create(:assignment, user: enlistment.user, unit: tp)

        assert_difference("Assignment.count", 0) do
          patch process_enlistment_manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: tp.id,
              status: "denied"
            }
          }
        end

        assert_equal "You are not authorized to perform this action.", flash[:alert]
      end

      test "does not modify or delete old enlistments or other active assignments" do
        tp = create(:unit, classification: :training)
        enlistment = create(:enlistment, unit: tp, status: :accepted)
        create(:assignment, user: enlistment.user, unit: tp)

        old_tp = create(:unit, classification: :training)
        create(:assignment, user: enlistment.user, unit: old_tp,
          start_date: 1.year.ago, end_date: 6.months.ago)

        staff_unit = create(:unit, classification: :staff)
        create(:assignment, user: enlistment.user, unit: staff_unit,
          start_date: 1.month.ago, end_date: nil)

        assert_difference("Assignment.count", -1) do
          patch process_enlistment_manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: tp.id,
              status: "denied"
            }
          }
        end

        assert_equal 2, enlistment.user.assignments.length
        assert_equal 1, enlistment.user.assignments.active.length
      end

      test "updates forum user when enlistment accepted" do
        enlistment = create(:enlistment)
        tp = create(:unit, classification: :training)

        assert_enqueued_with(job: UpdateDiscourseDisplayNameJob, args: [enlistment.user]) do
          patch process_enlistment_manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: tp.id,
              status: "accepted"
            }
          }
        end
      end

      test "validation errors redirect back to process enlistment form" do
        enlistment = create(:enlistment)
        tp = create(:unit, classification: :training)

        assert_difference("Assignment.count", 0) do
          patch process_enlistment_manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: tp.id,
              status: ""
            }
          }
        end

        assert_select "#page_title", "Process Enlistment"
      end

      test "sets recruiter user" do
        enlistment = create(:enlistment)
        tp = create(:unit, classification: :training)
        recruiter = create(:user)

        patch process_enlistment_manage_enlistment_url(enlistment), params: {
          enlistment: {
            unit_id: tp.id,
            status: "pending",
            recruiter_member_id: recruiter.id
          }
        }
        enlistment.reload

        assert_equal recruiter, enlistment.recruiter_user
      end

      test "assignment created uses recruit position" do
        enlistment = create(:enlistment)
        tp = create(:unit, classification: :training)

        patch process_enlistment_manage_enlistment_url(enlistment), params: {
          enlistment: {
            unit_id: tp.id,
            status: "accepted"
          }
        }

        created_assignment = Assignment.last
        assert_equal "Recruit", created_assignment.position.name
      end

      test "enlistment liaison cannot assign to unit other than training platoon" do
        enlistment = create(:enlistment)
        combat_unit = create(:unit, classification: :combat)

        assert_difference("Assignment.count", 0) do
          patch process_enlistment_manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: combat_unit.id,
              status: "accepted"
            }
          }
        end
        enlistment.reload

        refute_equal combat_unit, enlistment.unit
        assert_select ".errors li"
      end

      test "destroys all active training assignments when not accepted" do
        tp = create(:unit, classification: :training)
        enlistment = create(:enlistment, unit: tp, status: :accepted)
        create(:assignment, user: enlistment.user, unit: tp)

        other_tp = create(:unit, classification: :training)
        create(:assignment, user: enlistment.user, unit: other_tp)

        assert_difference("Assignment.count", -2) do
          patch process_enlistment_manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: tp.id,
              status: "denied"
            }
          }
        end

        assert_equal 0, enlistment.user.assignments.length
      end

      test "ensures no more than one active training assignment" do
        tp = create(:unit, classification: :training)
        enlistment = create(:enlistment, unit: tp, status: :accepted)
        create(:assignment, user: enlistment.user, unit: tp)

        other_tp = create(:unit, classification: :training)
        create(:assignment, user: enlistment.user, unit: other_tp)

        new_tp = create(:unit, classification: :training)

        assert_difference("Assignment.count", -1) do
          patch process_enlistment_manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: new_tp.id,
              status: "accepted"
            }
          }
        end

        assert_equal 1, enlistment.user.assignments.length
      end
    end
  end
end
