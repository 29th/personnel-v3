require "test_helper"

class StandardProgressCalculatorTest < ActiveSupport::TestCase
  attr_reader :user, :game

  setup do
    @user = create(:user)
    @game = "dh"

    # Create EIB award
    @eib_award = create(:award, code: "eib")

    # Create weapon awards for DH game
    @marksman_rifle_award = create(:award, code: "m:rifle:dh")
    @sharpshooter_rifle_award = create(:award, code: "s:rifle:dh")
    @expert_rifle_award = create(:award, code: "e:rifle:dh")
  end

  class EIBTests < StandardProgressCalculatorTest
    setup do
      # Create EIB standards (10 total standards for easy percentage calculation)
      # EIB standards use the same game as the unit since model validates game presence
      @eib_standards = create_list(:ait_standard, 10, weapon: :eib, badge: :notapplicable, game: "dh")
    end

    test "when a user has no progress toward eib, it returns 0" do
      result = StandardProgressCalculator.call([user], game)

      assert_equal 0, result[user.id][:eib][:notapplicable]
    end

    test "when a user has progress toward eib but no award, it returns the correct percentage" do
      # User has completed 3 out of 10 EIB standards (30%)
      @eib_standards.first(3).each do |standard|
        create(:ait_qualification, user:, ait_standard: standard)
      end

      result = StandardProgressCalculator.call([user], game)

      assert_equal 30, result[user.id][:eib][:notapplicable]
    end

    test "when a user has received the eib award after a non-honorable discharge, it returns :award" do
      # Non-honorable discharge occurs before award
      create(:discharge, user:, type: :general, date: 2.years.ago)
      create(:user_award, user:, award: @eib_award, date: 1.year.ago)

      result = StandardProgressCalculator.call([user], game)

      assert_equal :award, result[user.id][:eib][:notapplicable]
    end

    test "when a user has received the eib award prior to a non-honorable discharge, it ignores the award and returns current percentage" do
      # Award received before discharge
      create(:user_award, user:, award: @eib_award, date: 2.years.ago)
      # Non-honorable discharge
      create(:discharge, user:, type: :general, date: 1.year.ago)

      # Current progress: 4 out of 10 standards (40%)
      @eib_standards.first(4).each do |standard|
        create(:ait_qualification, user:, ait_standard: standard)
      end

      result = StandardProgressCalculator.call([user], game)

      assert_equal 40, result[user.id][:eib][:notapplicable]
    end
  end

  class WeaponBadgeTests < StandardProgressCalculatorTest
    setup do
      # Create rifle standards for DH game (10 standards each for easy percentage calculation)
      @marksman_standards = create_list(:ait_standard, 10, weapon: :rifle, badge: :marksman, game: "dh")
      @sharpshooter_standards = create_list(:ait_standard, 10, weapon: :rifle, badge: :sharpshooter, game: "dh")
      @expert_standards = create_list(:ait_standard, 10, weapon: :rifle, badge: :expert, game: "dh")

      # Create standards for a different game (RS) that should be ignored
      @rs_marksman_standards = create_list(:ait_standard, 5, weapon: :rifle, badge: :marksman, game: "rs")
    end

    test "when a user has received a weapon badge, it returns :award for that badge, and progress toward other badges" do
      # Progress toward marksman: 10 out of 10 standards (100%)
      @marksman_standards.each do |standard|
        create(:ait_qualification, user:, ait_standard: standard)
      end

      # Sharpshooter badge received
      create(:user_award, user:, award: @sharpshooter_rifle_award)

      # Progress toward expert: 6 out of 10 standards (60%)
      @expert_standards.first(6).each do |standard|
        create(:ait_qualification, user:, ait_standard: standard)
      end

      result = StandardProgressCalculator.call([user], game)

      assert_equal 100, result[user.id][:rifle][:marksman]
      assert_equal :award, result[user.id][:rifle][:sharpshooter]
      assert_equal 60, result[user.id][:rifle][:expert]
    end

    test "it only considers awards from the game that the unit plays" do
      # Create awards for different games
      rs_marksman_award = create(:award, code: "m:rifle:rs")

      # User receives marksman award for RS game (wrong game)
      create(:user_award, user:, award: rs_marksman_award)

      # User also has progress toward sharpshooter for DH game (correct game)
      @marksman_standards.first(7).each do |standard|
        create(:ait_qualification, user:, ait_standard: standard)
      end

      result = StandardProgressCalculator.call([user], game)

      # RS award should be ignored, so marksman shows progress, not :award
      assert_equal 70, result[user.id][:rifle][:marksman]
    end

    test "it only considers standards from the game that the unit plays" do
      # Progress toward expert for DH game: 3 out of 10 standards (30%)
      @expert_standards.first(3).each do |standard|
        create(:ait_qualification, user:, ait_standard: standard)
      end

      # Progress toward expert for RS game (should be ignored)
      rs_expert_standards = create_list(:ait_standard, 5, weapon: :rifle, badge: :expert, game: "rs")
      rs_expert_standards.each do |standard|
        create(:ait_qualification, user:, ait_standard: standard)
      end

      result = StandardProgressCalculator.call([user], game)

      assert_equal 30, result[user.id][:rifle][:expert]
    end

    test "when a user has no weapon badges and no progress, it returns 0" do
      result = StandardProgressCalculator.call([user], game)

      assert_equal 0, result[user.id][:rifle][:marksman]
      assert_equal 0, result[user.id][:rifle][:sharpshooter]
      assert_equal 0, result[user.id][:rifle][:expert]
    end
  end
end
