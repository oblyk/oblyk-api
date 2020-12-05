# frozen_string_literal: true

json.extract! photo,
              :id,
              :description,
              :exif_model,
              :exif_make,
              :source,
              :alt,
              :copyright_by,
              :copyright_nc,
              :copyright_nd
json.picture url_for(photo.picture)
json.illustrable do
  json.type photo.illustrable_type
  json.id photo.illustrable.id
  json.name photo.illustrable.name
end
json.creator do
  json.id photo.user_id
  json.name photo.user&.full_name
end
json.history do
  json.extract! photo, :created_at, :updated_at
end
