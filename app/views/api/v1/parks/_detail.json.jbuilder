# frozen_string_literal: true

json.extract! park,
              :id,
              :description
json.localization do
  json.extract! park,
                :latitude,
                :longitude
end
json.creator do
  json.id park.user_id
  json.name park.user&.full_name
end
json.history do
  json.extract! park, :created_at, :updated_at
end
