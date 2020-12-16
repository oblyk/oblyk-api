# frozen_string_literal: true

json.partial! 'api/v1/crag_sectors/short_detail', crag_sector: crag_sector

json.photo_count crag_sector.photos.count

json.creator do
  json.id crag_sector.user_id
  json.name crag_sector.user&.full_name
end
json.history do
  json.extract! crag_sector, :created_at, :updated_at
end
