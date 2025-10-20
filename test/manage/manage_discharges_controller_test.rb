require "test_helper"

module Manage
  class DischargesControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    setup do
      @user_unit = create(:unit)
      create(:permission, :leader, abbr: "manage", unit: @user_unit)
      create(:permission, :leader, abbr: "discharge_add", unit: @user_unit)

      @user = create(:user)
      create(:assignment, :leader, user: @user, unit: @user_unit)

      @subject = create(:user)
      clear_enqueued_jobs
    end

    test "should end assignments and update forum roles after creation" do
      sign_in_as @user
      unit = create(:unit, parent: @user_unit)
      create(:assignment, user: @subject, unit: unit)
      discharge = build(:discharge, user: @subject)

      assert_enqueued_with(job: UpdateDiscourseRolesJob, args: [@subject]) do
        post manage_discharges_url, params: {
          discharge: {
            **discharge_attributes(discharge),
            end_assignments: true
          }
        }
      end

      refute @subject.member?, "user is still a member"
    end

    test "should not end assignments or update forum roles if end_assignments wasn't ticked" do
      sign_in_as @user
      unit = create(:unit, parent: @user_unit)
      create(:assignment, user: @subject, unit: unit)
      discharge = build(:discharge, user: @subject, end_assignments: false)

      assert_no_enqueued_jobs only: UpdateDiscourseRolesJob do
        post manage_discharges_url, params: {discharge: discharge_attributes(discharge)}
      end

      assert @subject.member?, "user is no longer a member"
    end

    private

    def discharge_attributes(discharge)
      discharge.attributes
        .symbolize_keys
        .slice(:member_id, :date, :type, :reason, :forum_id, :topic_id)
    end
  end
end
