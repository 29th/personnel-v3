require "test_helper"

class Admin::DischargesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_unit = create(:unit)
    create(:permission, :leader, abbr: "discharge_add", unit: @user_unit)

    @user = create(:user)
    create(:assignment, :leader, user: @user, unit: @user_unit)

    @subject = create(:user)
  end

  test "should end assignments and update forum roles after creation" do
    sign_in_as @user
    unit = create(:unit, parent: @user_unit)
    create(:assignment, user: @subject, unit: unit)
    discharge = build(:discharge, user: @subject)

    methods_called = []
    User.stub_any_instance(:update_forum_roles, -> { methods_called << :update_forum_roles }) do
      post admin_discharges_url, params: {
        discharge: {
          **discharge_attributes(discharge),
          end_assignments: true
        }
      }
    end

    puts @subject.assignments.active

    refute @subject.member?, "user is still a member"
    assert_includes methods_called, :update_forum_roles
  end

  test "should not end assignments or update forum roles if end_assignments wasn't ticked" do
    sign_in_as @user
    unit = create(:unit, parent: @user_unit)
    create(:assignment, user: @subject, unit: unit)
    discharge = build(:discharge, user: @subject, end_assignments: false)

    methods_called = []
    User.stub_any_instance(:update_forum_roles, -> { methods_called << :update_forum_roles }) do
      post admin_discharges_url, params: {promotion: discharge_attributes(discharge)}
    end

    assert @subject.member?, "user is no longer a member"
    refute_includes methods_called, :update_forum_roles
  end

  private

  def discharge_attributes(discharge)
    discharge.attributes
      .symbolize_keys
      .slice(:member_id, :date, :type, :reason, :forum_id, :topic_id)
  end
end
