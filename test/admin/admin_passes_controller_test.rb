require "test_helper"

class Admin::PassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    unit = create(:unit)
    create(:permission, :leader, abbr: "pass_edit", unit: unit)

    @user = create(:user)
    create(:assignment, :leader, user: @user, unit: unit)

    @subject = create(:user)
    create(:assignment, user: @subject, unit: unit)

    @subject2 = create(:user)
    create(:assignment, user: @subject2, unit: unit)
  end

  test "should create one pass" do
    sign_in_as @user
    pass = build(:pass)
    assert_difference("Pass.count") do
      post admin_passes_url, params: {
        pass: {
          bulk_member_ids: ["", @subject.id],
          start_date: pass.start_date,
          end_date: pass.end_date,
          type: pass.type,
          reason: pass.reason
        }
      }
    end

    assert_redirected_to admin_pass_url(Pass.last)
  end

  test "should create multiple passes" do
    sign_in_as @user
    pass = build(:pass)
    assert_difference("Pass.count", 2) do
      post admin_passes_url, params: {
        pass: {
          bulk_member_ids: ["", @subject.id, @subject2.id],
          start_date: pass.start_date,
          end_date: pass.end_date,
          type: pass.type,
          reason: pass.reason
        }
      }
    end

    assert_redirected_to admin_passes_url
  end

  test "should fail without creating any passes if not authorized on all users" do
    sign_in_as @user
    pass = build(:pass)
    non_subordinate_subject = create(:user)

    assert_difference("Pass.count", 0) do
      post admin_passes_url, params: {
        pass: {
          bulk_member_ids: ["", @subject.id, non_subordinate_subject.id],
          start_date: pass.start_date,
          end_date: pass.end_date,
          type: pass.type,
          reason: pass.reason
        }
      }
    end

    assert_equal "You are not authorized to perform this action.", flash[:alert]
  end

  test "should update pass" do
    sign_in_as @user
    pass = create(:pass, user: @subject)
    patch admin_pass_url(pass), params: {
      pass: {
        member_id: pass.user.id,
        start_date: pass.start_date,
        end_date: pass.end_date,
        type: pass.type,
        reason: pass.reason
      }
    }
    assert_redirected_to admin_pass_url(pass)
  end

  test "should destroy pass" do
    sign_in_as @user
    pass = create(:pass, user: @subject)
    assert_difference("Pass.count", -1) do
      delete admin_pass_url(pass)
    end

    assert_redirected_to admin_passes_url
  end
end
