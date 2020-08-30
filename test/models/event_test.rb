require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test "invalid without required fields" do
    # TODO require server_id once server model is created
    required_fields = %i(type datetime unit)
    required_fields.each do |field|
      event = build(:event, field => nil)
      refute event.valid?
    end
  end
end
