ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def sign_in_as(user)
    payload = { sub: user.forum_member_id }
    token = JsonWebToken.encode(payload)
    cookie_name = ENV['VANILLA_COOKIE_NAME']
    cookies[cookie_name] = token
  end

  # Pundit helpers
  # https://github.com/varvet/pundit/issues/204#issuecomment-60166450
  def assert_permit(user, record, action)
    msg = "User #{user.inspect} should be permitted to #{action} #{record}, but isn't permitted"
    assert permit(user, record, action), msg
  end
  
  def refute_permit(user, record, action)
    msg = "User #{user.inspect} should NOT be permitted to #{action} #{record}, but is permitted"
    refute permit(user, record, action), msg
  end
  
  def permit(user, record, action)
    index = self.class.name.index('Policy')
    klass = self.class.name[0, index+6]
    klass.constantize.new(user, record).public_send("#{action.to_s}?")
  end
end

class ActiveRecord::FixtureSet
  # Fixtures was generating IDs that were larger than the DB columns could support
  remove_const(:MAX_ID) if const_defined?(:MAX_ID)
  const_set(:MAX_ID, 2 ** 15 -1)
end
