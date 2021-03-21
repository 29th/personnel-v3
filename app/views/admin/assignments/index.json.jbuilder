json.array! @assignments do |assignment|
  json.call(assignment, :id, :start_date, :end_date)
  json.user do
    json.call(assignment.user, :id, :short_name)
  end
  json.unit do
    json.call(assignment.unit, :id, :abbr, :name)
  end
  json.position do
    json.call(assignment.position, :id, :name)
  end
end
