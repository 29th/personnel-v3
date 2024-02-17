# A user who has signed in via Discourse SSO but who has
# never enlisted, and has no matching user record in the
# personnel database. Imitates User class.
class UnregisteredUser
  include ActiveModel::Model

  attr_reader :forum_member_id, :forum_member_username,
    :forum_member_email, :time_zone

  alias_method :full_name, :forum_member_username
  alias_method :short_name, :forum_member_username
  alias_method :to_s, :forum_member_username

  validates :forum_member_id, presence: true, numericality: {only_integer: true}

  def initialize(discourse_sso_data)
    @forum_member_id = discourse_sso_data[:uid]
    @forum_member_username = discourse_sso_data["info"]["nickname"]
    @forum_member_email = discourse_sso_data["info"]["email"]
    @time_zone = discourse_sso_data["info"]["time_zone"]
  end

  def id = nil

  def persisted? = false

  def member? = false

  def honorably_discharged? = false

  def cadet? = false

  def has_permission?(_permission) = false

  def has_permission_on_unit?(_permission, _unit) = false

  def has_permission_on_user?(_permission, _user) = false

  def active_admin_editor? = false

  def has_pending_enlistment? = false
end
