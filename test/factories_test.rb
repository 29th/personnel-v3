require "test_helper"

class FactoriesTest < ActiveSupport::TestCase
  FactoryBot.factories.map(&:name).each do |factory_name|
    test "#{factory_name} factory is valid" do
      instance = build(factory_name)
      assert instance.valid?, instance.errors.full_messages.inspect
    end
  end
end
