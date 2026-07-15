require "test_helper"

module Manage
  class UsersControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    setup do
      unit = create(:unit)
      create(:permission, abbr: "manage", unit: unit)
      create(:permission, abbr: "profile_edit_any", unit: unit)

      @user = create(:user)
      create(:assignment, user: @user, unit: unit)

      @subject = create(:user)

      sign_in_as @user
      clear_enqueued_jobs
    end

    test "renaming a user updates forum display name and regenerates coat" do
      assert_enqueued_with(job: UpdateDiscourseDisplayNameJob, args: [@subject]) do
        assert_enqueued_with(job: GenerateServiceCoatJob, args: [@subject]) do
          patch manage_user_url(@subject), params: {
            user: {last_name: "Zulu"}
          }
        end
      end

      assert_equal "Zulu", @subject.reload.last_name
    end

    test "changing attributes not shown on the forum does not enqueue jobs" do
      patch manage_user_url(@subject), params: {
        user: {first_name: "Newname"}
      }

      assert_equal "Newname", @subject.reload.first_name
      assert_no_enqueued_jobs
    end
  end
end
