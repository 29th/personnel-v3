class Audit < Audited::Audit
  def action_past
    case action
    when "create"
      "created"
    when "update"
      "updated"
    when "delete"
      "deleted"
    else
      action
    end
  end
end
