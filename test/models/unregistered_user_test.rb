require "test_helper"

class UnregisteredUserTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  setup do
    @model = build(:unregistered_user)
  end

  test "member? is false" do
    refute @model.member?
  end

  test "active_admin_editor? is false" do
    refute @model.active_admin_editor?
  end

  test "to_normal_user creates a valid user with params and session data" do
    create(:rank, name: "Recruit")
    params = {first_name: "John", last_name: "Doe"}
    user = @model.to_normal_user(params)
    assert user.valid?
    assert_equal params[:last_name], user.last_name
    assert_equal @model.forum_member_id, user.forum_member_id
  end
end
