# frozen_string_literal: true

json.partial! 'api/v1/crag_sectors/short_detail', crag_sector: crag_sector

json.versions_count crag_sector.versions.count
json.photo_count crag_sector.photos.count

json.creator do
  json.uuid crag_sector.user&.uuid
  json.name crag_sector.user&.full_name
  json.slug_name crag_sector.user&.slug_name
end
json.history do
  json.extract! crag_sector, :created_at, :updated_at
end
