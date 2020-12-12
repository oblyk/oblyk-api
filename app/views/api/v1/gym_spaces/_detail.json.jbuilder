# frozen_string_literal: true

json.partial! 'api/v1/gym_spaces/short_detail', gym_space: gym_space

json.gym_sectors do
  json.array! gym_space.gym_sectors do |gym_sector|
    json.partial! 'api/v1/gym_sectors/short_detail', gym_sector: gym_sector
  end
end
