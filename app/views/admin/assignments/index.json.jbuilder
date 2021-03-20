json.array! @assignments do |assignment|
  json.(assignment, :id, :start_date, :end_date)
  json.user do
    json.(assignment.user, :id, :short_name)
  end
  json.unit do
    json.(assignment.unit, :id, :abbr, :name)
  end
  json.position do
    json.(assignment.position, :id, :name)
  end
end
