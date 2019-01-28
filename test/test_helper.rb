ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActiveRecord::FixtureSet
  # Fixtures was generating IDs that were larger than the DB columns could support
  remove_const(:MAX_ID) if const_defined?(:MAX_ID)
  const_set(:MAX_ID, 2 ** 15 -1)
end
