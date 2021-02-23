# frozen_string_literal: true

json.extract! video,
              :id,
              :url,
              :description,
              :viewable_type,
              :viewable_id
json.iframe video.iframe
json.creator do
  json.uuid video.user&.uuid
  json.name video.user&.full_name
  json.slug_name video.user&.slug_name
end
json.history do
  json.extract! video, :created_at, :updated_at
end
