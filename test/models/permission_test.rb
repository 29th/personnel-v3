require "test_helper"

class PermissionTest < ActiveSupport::TestCase
  test "invalid if combination already exists" do
    unit = create(:unit)
    ability = create(:ability)
    create(:permission, unit: unit, ability: ability, access_level: :member)

    subject = build(:permission, unit: unit, ability: ability, access_level: :member)
    refute subject.valid?
  end
end
