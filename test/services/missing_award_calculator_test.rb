require "test_helper"

class MissingAwardCalculatorTest < ActiveSupport::TestCase
  attr_reader :user

  setup do
    @user = create(:user)
    @aocc = create(:award, code: "aocc")
    @ww1v = create(:award, code: "ww1v")
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
end
