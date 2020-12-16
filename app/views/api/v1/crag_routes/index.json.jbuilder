# frozen_string_literal: true

json.array! @crag_routes do |crag_route|
  json.partial! 'api/v1/crag_routes/short_detail', crag_route: crag_route
end
