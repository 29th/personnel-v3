require "test_helper"

class Admin::AssignmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_unit = create(:unit)
    create(:permission, :leader, abbr: "promotion_add", unit: @user_unit)

    @user = create(:user)
    create(:assignment, :leader, user: @user, unit: @user_unit)

    @subject = create(:user)
  end

  test "should refresh rank, update coat, and forum display name after creation" do
    sign_in_as @user
    unit = create(:unit, parent: @user_unit)
    create(:assignment, user: @subject, unit: unit)
    rank = create(:rank, abbr: "Sgt.")
    promotion = build(:promotion, user: @subject, new_rank: rank)

    methods_called = []
    User.stub_any_instance(:update_forum_display_name, -> { methods_called << :update_forum_display_name }) do
      User.stub_any_instance(:update_coat, -> { methods_called << :update_coat }) do
        post admin_promotions_url, params: {promotion: required_attributes(promotion)}
      end
    end

    @subject.reload
    assert_equal "Sgt.", @subject.rank.abbr

    assert_includes methods_called, :update_forum_display_name
    assert_includes methods_called, :update_coat
  end

  test "should refresh rank, update coat, and forum display name after deletion" do
    sign_in_as @user
    unit = create(:unit, parent: @user_unit)
    create(:assignment, user: @subject, unit: unit)
    old_promotion = create(:promotion, user: @subject, rank_abbr: "Cpl.")
    promotion = create(:promotion, user: @subject, rank_abbr: "Sgt.")

    methods_called = []
    User.stub_any_instance(:update_forum_display_name, -> { methods_called << :update_forum_display_name }) do
      User.stub_any_instance(:update_coat, -> { methods_called << :update_coat }) do
        delete admin_promotion_url(promotion)
      end
    end

    @subject.reload
    assert_equal old_promotion.new_rank.abbr, @subject.rank.abbr

    assert_includes methods_called, :update_forum_display_name
    assert_includes methods_called, :update_coat
  end

  private

  def required_attributes(promotion)
    promotion.attributes
      .symbolize_keys
      .slice(:member_id, :date, :old_rank_id, :new_rank_id, :forum_id, :topic_id)
  end
end
