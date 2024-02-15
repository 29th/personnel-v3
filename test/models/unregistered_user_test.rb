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
end
