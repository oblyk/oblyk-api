# frozen_string_literal: true

json.extract! video, :id, :url, :description
json.iframe video.iframe
json.creator do
  json.id video.user_id
  json.name video.user&.full_name
end
json.history do
  json.extract! video, :created_at, :updated_at
end
