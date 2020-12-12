# frozen_string_literal: true

json.array! @gym_sectors do |gym_sector|
  json.partial! 'api/v1/gym_sectors/detail', gym_sector: gym_sector
end
