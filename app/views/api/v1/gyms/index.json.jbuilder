# frozen_string_literal: true

json.array! @gyms do |gym|
  json.partial! 'api/v1/gyms/short_detail', gym: gym
end
