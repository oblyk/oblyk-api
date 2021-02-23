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
              :copyright_nd,
              :photo_height,
              :photo_width
json.picture url_for(photo.picture)
json.thumbnail photo.thumbnail_url
json.illustrable do
  json.type photo.illustrable_type
  json.id photo.illustrable.id
  json.name photo.illustrable.rich_name
  json.slug_name photo.illustrable.slug_name
  json.location photo.illustrable.location
  if %w[CragSector CragRoute].include? photo.illustrable_type
    json.crag do
      json.id photo.illustrable.crag.id
      json.name photo.illustrable.crag.name
      json.slug_name photo.illustrable.crag.slug_name
    end
  end
end
json.creator do
  json.uuid photo.user&.uuid
  json.name photo.user&.full_name
  json.slug_name photo.user&.slug_name
end
json.history do
  json.extract! photo, :created_at, :updated_at
end
