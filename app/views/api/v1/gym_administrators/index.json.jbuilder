# frozen_string_literal: true

json.array! @gym_administrators do |gym_administrator|
  json.partial! 'api/v1/gym_administrators/detail', gym_administrator: gym_administrator
end
