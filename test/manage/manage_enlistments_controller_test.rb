require "test_helper"

class Manage::EnlistmentsControllerTest < ActionDispatch::IntegrationTest
  class ProcessEnlistmentTest < Manage::EnlistmentsControllerTest
    setup do
      unit = build_stubbed(:unit)
      create(:permission, abbr: "enlistment_process_any", unit: unit)

      user = build_stubbed(:user)
      create(:assignment, user: user, unit: unit)

      sign_in_as user
    end

    test "creates assignment when status set to accepted and unit set" do
      enlistment = build_stubbed(:enlistment)
      tp = build_stubbed(:unit, classification: :training)

      assert_difference("Assignment.count", 1) do
        post manage_enlistment_url(enlistment), params: {
          enlistment: {
            unit_id: tp.id,
            status: "accepted"
          }
        }
      end
      assert_redirected_to manage_enlistment_url(enlistment)

      created_assignment = Assignment.last
      assert created_assignment.user = enlistment.user
      assert created_assignment.unit = tp
      assert created_assignment.start_date = Date.today
    end

    test "creates assignment when status set to accepted and unit already set" do
      tp = build_stubbed(:unit, classification: :training)
      enlistment = build_stubbed(:enlistment, unit: tp)

      assert_difference("Assignment.count", 1) do
        post manage_enlistment_url(enlistment), params: {
          enlistment: {
            unit_id: tp.id,
            status: "accepted",
            recruiter_user_id: ""
          }
        }
      end
      assert_redirected_to manage_enlistment_url(enlistment)

      created_assignment = Assignment.last
      assert created_assignment.user = enlistment.user
      assert created_assignment.unit = tp
      assert created_assignment.start_date = Date.today
    end

    test "does not create assignment if unit set but status not set to accepted" do
      enlistment = build_stubbed(:enlistment)
      tp = build_stubbed(:unit, classification: :training)

      assert_difference("Assignment.count", 0) do
        post manage_enlistment_url(enlistment), params: {
          enlistment: {
            unit_id: tp.id,
            status: "pending"
          }
        }
      end
      assert_redirected_to manage_enlistment_url(enlistment)
    end

    test "changes assignment when already accepted and unit changed" do
      old_tp = build_stubbed(:unit, classification: :training)
      enlistment = build_stubbed(:enlistment, unit: old_tp, status: accepted)
      build_stubbed(:assignment, user: enlistment.user, unit: old_tp)
      new_tp = build_stubbed(:unit, classification: :training)

      assert_difference("Assignment.count", 0) do
        post manage_enlistment_url(enlistment), params: {
          enlistment: {
            unit_id: new_tp.id,
            status: "accepted"
          }
        }
      end

      assignments = enlistment.user.assignments.active.training
      assert assignments.length == 1
      assert assignments[0].unit == new_tp
    end

    ["pending", "denied", "withdrawn"].each do |status|
      test "destroys assignment when status set to #{status} and already assigned" do
        tp = build_stubbed(:unit, classification: :training)
        enlistment = build_stubbed(:enlistment, unit: tp, status: accepted)
        build_stubbed(:assignment, user: enlistment.user, unit: tp)

        assert_difference("Assignment.count", -1) do
          post manage_enlistment_url(enlistment), params: {
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
      tp = build_stubbed(:unit, classification: :training)
      enlistment = build_stubbed(:enlistment, unit: tp, status: accepted)
      build_stubbed(:assignment, user: enlistment.user, unit: tp)

      assert_difference("Assignment.count", 0) do
        post manage_enlistment_url(enlistment), params: {
          enlistment: {
            unit_id: tp.id,
            status: "awol"
          }
        }
      end

      assignments = enlistment.user.assignments.training
      assert assignments.length == 1
      assert assignments[0].end_date == Date.today
    end

    test "does not allow changes to enlistments from more than 3 months ago" do
      tp = build_stubbed(:unit, classification: :training)
      enlistment = build_stubbed(:enlistment, unit: tp, status: accepted)
      build_stubbed(:assignment, user: enlistment.user, unit: tp)

      assert_difference("Assignment.count", 0) do
        post manage_enlistment_url(enlistment), params: {
          enlistment: {
            unit_id: tp.id,
            status: "denied"
          }
        }
      end

      assert_equal "You are not authorized to perform this action.", flash[:alert]
    end

    test "does not modify or delete old enlistments or other active assignments" do
      tp = build_stubbed(:unit, classification: :training)
      enlistment = build_stubbed(:enlistment, unit: tp, status: accepted)
      build_stubbed(:assignment, user: enlistment.user, unit: tp)

      old_tp = build_stubbed(:unit, classification: :training)
      build_stubbed(:assignment, user: enlistment.user, unit: old_tp,
        start_date: 1.year.ago, end_date: 6.months.ago)

      staff_unit = build_stubbed(:unit, classification: :staff)
      build_stubbed(:assignment, user: enlistment.user, unit: staff_unit,
        start_date: 1.month.ago, end_date: nil)

      assert_difference("Assignment.count", -1) do
        post manage_enlistment_url(enlistment), params: {
          enlistment: {
            unit_id: tp.id,
            status: "denied"
          }
        }
      end

      assert enlistment.user.assignments.length == 2
      assert enlistment.user.assignments.active.length == 1
    end

    test "updates forum user when enlistment accepted" do
      enlistment = build_stubbed(:enlistment)
      tp = build_stubbed(:unit, classification: :training)

      methods_called = []
      User.stub_any_instance(:update_display_name, -> { methods_called << :update_display_name }) do
        post manage_enlistment_url(enlistment), params: {
          enlistment: {
            unit_id: tp.id,
            status: "accepted"
          }
        }
      end

      assert_includes methods_called, :update_display_name
    end

    test "validation errors redirect back to process enlistment form" do
      enlistment = build_stubbed(:enlistment)
      tp = build_stubbed(:unit, classification: :training)

      assert_difference("Assignment.count", 0) do
        post manage_enlistment_url(enlistment), params: {
          enlistment: {
            unit_id: tp.id,
            status: ""
          }
        }
      end

      assert_redirected_to process_enlistment_manage_enlistment_url(enlistment)
    end

    test "sets recruiter user" do
      enlistment = build_stubbed(:enlistment)
      tp = build_stubbed(:unit, classification: :training)
      recruiter = build_stubbed(:user)

      post manage_enlistment_url(enlistment), params: {
        enlistment: {
          unit_id: tp.id,
          status: "pending",
          recruiter_user_id: recruiter.id
        }
      }

      assert enlistment.recruiter_user == recruiter
    end
  end
end
