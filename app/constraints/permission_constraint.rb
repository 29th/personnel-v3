class PermissionConstraint
  def initialize(permission)
    @permission = permission
  end

  def matches?(request)
    # Use find_by_id to avoid raising an error if the user is not found
    user = User.find_by_id(request.session[:user_id])

    user&.has_permission?(@permission)
  end
end
