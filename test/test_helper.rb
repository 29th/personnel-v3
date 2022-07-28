ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"
require "minitest/stub_any_instance"

WebMock.disable_net_connect!(allow_localhost: true)

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # Add more helper methods to be used by all tests here...
  def sign_in_as(user)
    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:discourse, {uid: user.forum_member_id})
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:discourse]
    post create_user_session_url(:discourse)
    OmniAuth.config.mock_auth[:discourse] = nil
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
    index = self.class.name.index("Policy")
    klass = self.class.name[0, index + 6]
    klass.constantize.new(user, record).public_send("#{action}?")
  end
end
