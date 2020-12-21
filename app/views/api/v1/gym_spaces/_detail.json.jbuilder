# frozen_string_literal: true

json.partial! 'api/v1/gym_spaces/short_detail', gym_space: gym_space

json.gym do
  json.id gym_space.gym.id
  json.slug_name gym_space.gym.slug_name
end

json.gym_sectors do
  json.array! gym_space.gym_sectors do |gym_sector|
    json.partial! 'api/v1/gym_sectors/short_detail', gym_sector: gym_sector
  end
end

json.gym_routes do
  json.array! gym_space.gym_routes do |gym_route|
    json.partial! 'api/v1/gym_routes/short_detail', gym_route: gym_route
  end
end

