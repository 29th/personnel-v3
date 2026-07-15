require "test_helper"

module Manage
  class UserAwardsControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    setup do
      unit = create(:unit)
      create(:permission, abbr: "manage", unit: unit)
      create(:permission, abbr: "awarding_add_any", unit: unit)

      @user = create(:user)
      create(:assignment, user: @user, unit: unit)

      @subject = create(:user)
      @award = create(:award)

      sign_in_as @user
      clear_enqueued_jobs
    end

    test "awarding a user regenerates their service coat" do
      assert_difference("UserAward.count") do
        assert_enqueued_with(job: GenerateServiceCoatJob, args: [@subject]) do
          post manage_user_awards_url, params: {
            user_award: {
              member_id: @subject.id,
              award_id: @award.id,
              date: Date.current,
              forum_id: "discourse",
              topic_id: 123
            }
          }
        end
      end
    end

    test "removing an award regenerates the service coat" do
      user_award = create(:user_award, user: @subject, award: @award)

      assert_difference("UserAward.count", -1) do
        assert_enqueued_with(job: GenerateServiceCoatJob, args: [@subject]) do
          delete manage_user_award_url(user_award)
        end
      end
    end
  end
end
