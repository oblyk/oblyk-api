# frozen_string_literal: true

json.extract! gym_administrator,
              :id,
              :user_id,
              :gym_id,
              :level
json.gym do
  json.name gym_administrator.gym.name
  json.id gym_administrator.gym.id
end
json.user do
  json.name gym_administrator.user.full_name
  json.id gym_administrator.user.id
end
