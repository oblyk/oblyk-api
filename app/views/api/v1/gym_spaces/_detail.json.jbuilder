# frozen_string_literal: true

json.partial! 'api/v1/gym_spaces/short_detail', gym_space: gym_space

json.gym do
  json.id gym_space.gym.id
  json.name gym_space.gym.name
  json.slug_name gym_space.gym.slug_name
  json.banner gym_space.gym.banner.attached? ? gym_space.gym.banner_large_url : nil
end

json.gym_sectors do
  json.array! gym_space.gym_sectors do |gym_sector|
    json.partial! 'api/v1/gym_sectors/short_detail', gym_sector: gym_sector
  end
end
