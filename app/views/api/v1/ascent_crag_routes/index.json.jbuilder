# frozen_string_literal: true

json.array! @ascent_crag_routes do |ascent_crag_route|
  json.partial! 'api/v1/ascent_crag_routes/detail', ascent_crag_route: ascent_crag_route
end
