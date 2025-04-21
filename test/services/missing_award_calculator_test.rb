require "test_helper"

class MissingAwardCalculatorTest < ActiveSupport::TestCase
  attr_reader :user

  setup do
    @user = create(:user)
    @aocc = create(:award, code: "aocc")
    @ww1v = create(:award, code: "ww1v")
    @cab1 = create(:award, code: "cab1")
    @cab2 = create(:award, code: "cab2")
    @cab3 = create(:award, code: "cab3")
    @cab4 = create(:award, code: "cab4")
  end

  class MissingServiceDurationAwards < MissingAwardCalculatorTest
    test "a user who is missing awards" do
      create(:assignment, user:, start_date: 3.years.ago)
      create(:user_award, user:, award: @aocc)

      result = MissingAwardCalculator.call(@user)

      assert_equal 5, result[:aocc]
      assert_equal 1, result[:ww1v]
    end

    test "a user who has the correct amount of awards" do
      create(:assignment, user:, start_date: 4.years.ago)
      create_list(:user_award, 8, user:, award: @aocc)
      create_list(:user_award, 2, user:, award: @ww1v)

      result = MissingAwardCalculator.call(@user)

      assert_equal 0, result[:aocc]
      assert_equal 0, result[:ww1v]
    end

    test "a user with more awards than they should have" do
      create(:assignment, user:, start_date: 4.years.ago)
      create_list(:user_award, 10, user:, award: @aocc)
      create_list(:user_award, 4, user:, award: @ww1v)

      result = MissingAwardCalculator.call(@user)

      assert_equal 0, result[:aocc]
      assert_equal 0, result[:ww1v]
    end

    test "a user who hasn't earned any awards yet" do
      create(:assignment, user:, start_date: 5.months.ago)

      result = MissingAwardCalculator.call(@user)

      assert_equal 0, result[:aocc]
      assert_equal 0, result[:ww1v]
    end

    test "a user who received awards prior to a past discharge" do
      create(:assignment, user:, start_date: 5.years.ago, end_date: 3.years.ago)
      create(:user_award, user:, award: @aocc, date: 4.years.ago)
      create(:user_award, user:, award: @ww1v, date: 4.years.ago)
      create(:discharge, user:, type: :general, date: 3.years.ago)
      create(:assignment, user:, start_date: 3.years.ago)

      result = MissingAwardCalculator.call(@user)

      assert_equal 6, result[:aocc]
      assert_equal 1, result[:ww1v]
    end
  end

  class MissingRecruitmentAwards < MissingAwardCalculatorTest
    test "a user who has recruited 2 members and is missing the CAB 1st award" do
      create_list(:enlistment, 2, recruiter_user: user, status: :accepted)

      result = MissingAwardCalculator.call(user)

      assert_equal 1, result[:cab1]
      assert_equal 0, result[:cab2]
      assert_equal 0, result[:cab3]
      assert_equal 0, result[:cab4]
    end

    test "a user who has recruited 5 members and is missing the CAB 1st and 2nd awards" do
      create_list(:enlistment, 5, recruiter_user: user, status: :accepted)

      result = MissingAwardCalculator.call(user)

      assert_equal 1, result[:cab1]
      assert_equal 1, result[:cab2]
      assert_equal 0, result[:cab3]
      assert_equal 0, result[:cab4]
    end

    test "a user who has recruited 10 members and is missing the CAB 1st, 2nd, and 3rd awards" do
      create_list(:enlistment, 10, recruiter_user: user, status: :accepted)

      result = MissingAwardCalculator.call(user)

      assert_equal 1, result[:cab1]
      assert_equal 1, result[:cab2]
      assert_equal 1, result[:cab3]
      assert_equal 0, result[:cab4]
    end

    test "a user who has recruited 20 members and is missing all CAB awards" do
      create_list(:enlistment, 20, recruiter_user: user, status: :accepted)

      result = MissingAwardCalculator.call(user)

      assert_equal 1, result[:cab1]
      assert_equal 1, result[:cab2]
      assert_equal 1, result[:cab3]
      assert_equal 1, result[:cab4]
    end

    test "a user who has already received some CAB awards" do
      create_list(:enlistment, 20, recruiter_user: user, status: :accepted)
      create(:user_award, user: user, award: @cab1)
      create(:user_award, user: user, award: @cab2)

      result = MissingAwardCalculator.call(user)

      assert_equal 0, result[:cab1]
      assert_equal 0, result[:cab2]
      assert_equal 1, result[:cab3]
      assert_equal 1, result[:cab4]
    end

    test "a user who has received awards prior to a past discharge" do
      create_list(:enlistment, 5, recruiter_user: user, status: :accepted)
      create(:user_award, user: user, award: @cab1, date: 4.years.ago)
      create(:discharge, user: user, type: :general, date: 3.years.ago)

      result = MissingAwardCalculator.call(user)

      assert_equal 1, result[:cab1]
      assert_equal 1, result[:cab2]
      assert_equal 0, result[:cab3]
      assert_equal 0, result[:cab4]
    end

    test "a user with pending enlistments that don't count towards awards" do
      create_list(:enlistment, 2, recruiter_user: user, status: :accepted)
      create_list(:enlistment, 3, recruiter_user: user, status: :pending)

      result = MissingAwardCalculator.call(user)

      assert_equal 1, result[:cab1]
      assert_equal 0, result[:cab2]
      assert_equal 0, result[:cab3]
      assert_equal 0, result[:cab4]
    end
  end

  test "a user with recruits from before a discharge" do
    create_list(:enlistment, 3, date: 4.years.ago, recruiter_user: user, status: :accepted)
    create(:discharge, user: user, type: :general, date: 3.years.ago)
    create_list(:enlistment, 2, date: 1.year.ago, recruiter_user: user, status: :accepted)

    result = MissingAwardCalculator.call(user)

    assert_equal 1, result[:cab1]
    assert_equal 0, result[:cab2]
  end
end
