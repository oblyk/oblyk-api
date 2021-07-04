# frozen_string_literal: true

json.array! @gym_routes do |gym_route|
  json.partial! 'api/v1/gym_routes/detail', gym_route: gym_route
end
