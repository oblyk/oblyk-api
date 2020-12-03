# frozen_string_literal: true

json.extract! tick_list, :id
json.crag_route do
  json.id tick_list.crag_route.id
  json.name tick_list.crag_route.name
end
json.history do
  json.extract! tick_list, :created_at, :updated_at
end
