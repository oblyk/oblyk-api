# frozen_string_literal: true

json.partial! 'api/v1/gym_sectors/short_detail', gym_sector: gym_sector
json.gym_route_count gym_sector.gym_routes.count
json.gym_routes do
  json.array! gym_sector.gym_routes do |gym_route|
    json.partial! 'api/v1/gym_routes/short_detail', gym_route: gym_route
  end
end
