json.array! @users do |user|
  json.call(user, :id, :last_name, :first_name,
    :middle_name, :short_name, :steam_id, :forum_member_id,
    :dropdown_label)
end
