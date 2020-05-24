require 'test_helper'

class FactoriesTest < ActiveSupport::TestCase
  FactoryBot.factories.map(&:name).each do |factory_name|
    test "#{factory_name} factory is valid" do
      assert build(factory_name).valid?
    end
  end
end
