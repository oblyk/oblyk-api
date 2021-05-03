# frozen_string_literal: true

json.extract! area, :id, :name, :slug_name
json.photo do
  json.id area.photo&.id
  json.url area.photo.large_url if area.photo
  json.thumbnail_url area.photo.thumbnail_url if area.photo
  json.illustrable_type area.photo.illustrable_type if area.photo
  json.illustrable_name area.photo.illustrable.rich_name if area.photo
end
