# frozen_string_literal: true

json.partial! 'api/v1/gyms/short_detail', gym: gym

json.follow_count gym.follows.count
json.gym_spaces do
  json.array! gym.gym_spaces do |gym_space|
    json.partial! 'api/v1/gym_spaces/short_detail', gym_space: gym_space
  end
end

json.creator do
  json.id gym.user_id
  json.name gym.user&.full_name
end
json.history do
  json.extract! gym, :created_at, :updated_at
end
