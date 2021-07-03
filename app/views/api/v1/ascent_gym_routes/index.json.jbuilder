# frozen_string_literal: true

json.array! @ascent_gym_routes do |ascent_gym_route|
  json.partial! 'api/v1/ascent_gym_routes/detail', ascent_gym_route: ascent_gym_route
end
