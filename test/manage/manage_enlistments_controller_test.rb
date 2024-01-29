require "test_helper"

class Manage::EnlistmentsControllerTest < ActionDispatch::IntegrationTest
  class ProcessEnlistmentTest < Manage::EnlistmentsControllerTest
    setup do
      endpoints = Rails.configuration.endpoints
      stub_request(:any, /#{endpoints[:vanilla][:base_url][:internal]}.*/)
      stub_request(:any, /#{endpoints[:discourse][:base_url][:internal]}.*/)

      unit = create(:unit)
      create(:permission, abbr: "enlistment_edit_any", unit: unit)
      create(:permission, abbr: "enlistment_process_any", unit: unit)
      create(:position, name: "Recruit")

      # TODO: fix access issue - see User#active_admin_editor?
      create(:permission, abbr: "pass_edit", unit: unit)

      @user = create(:user)
      create(:assignment, user: @user, unit: unit)
      sign_in_as @user
    end

    test "creates assignment when status set to accepted and unit set" do
      enlistment = create(:enlistment)
      tp = create(:unit, classification: :training)

      assert_difference("Assignment.count", 1) do
        patch manage_enlistment_url(enlistment), params: {
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
        patch manage_enlistment_url(enlistment), params: {
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
        patch manage_enlistment_url(enlistment), params: {
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
        patch manage_enlistment_url(enlistment), params: {
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
          patch manage_enlistment_url(enlistment), params: {
            enlistment: {
              unit_id: tp.id,
              status: status
            }
          }
        end

        assert enlistment.user.assignments.empty?
      end
    end

    test "ends assignment when status set to awol and already assigned" do
      tp = create(:unit, classification: :training)
      enlistment = create(:enlistment, unit: tp, status: :accepted)
      create(:assignment, user: enlistment.user, unit: tp)

      assert_difference("Assignment.count", 0) do
        patch manage_enlistment_url(enlistment), params: {
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
        patch manage_enlistment_url(enlistment), params: {
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
        patch manage_enlistment_url(enlistment), params: {
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

      methods_called = []
      User.stub_any_instance(:update_forum_display_name, -> { methods_called << :update_forum_display_name }) do
        patch manage_enlistment_url(enlistment), params: {
          enlistment: {
            unit_id: tp.id,
            status: "accepted"
          }
        }
      end

      assert_includes methods_called, :update_forum_display_name
    end

    test "validation errors redirect back to process enlistment form" do
      skip "not implemented yet"

      enlistment = create(:enlistment)
      tp = create(:unit, classification: :training)

      assert_difference("Assignment.count", 0) do
        patch manage_enlistment_url(enlistment), params: {
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

      patch manage_enlistment_url(enlistment), params: {
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

      patch manage_enlistment_url(enlistment), params: {
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
        patch manage_enlistment_url(enlistment), params: {
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
        patch manage_enlistment_url(enlistment), params: {
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
        patch manage_enlistment_url(enlistment), params: {
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
