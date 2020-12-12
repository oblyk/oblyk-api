# frozen_string_literal: true

json.array! @gym_spaces do |gym_space|
  json.partial! 'api/v1/gym_spaces/detail', gym_space: gym_space
end
