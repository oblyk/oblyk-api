# frozen_string_literal: true

json.partial! 'api/v1/crag_sectors/short_detail', crag_sector: crag_sector

json.versions_count crag_sector.versions.count
json.photo_count crag_sector.photos.count

json.routes_figures do
  json.count crag_sector.crag_routes_count
  json.grade do
    json.min_value crag_sector.min_grade_value
    json.max_value crag_sector.max_grade_value
    json.max_text crag_sector.max_grade_text
    json.min_text crag_sector.min_grade_text
  end
end

json.creator do
  json.uuid crag_sector.user&.uuid
  json.name crag_sector.user&.full_name
  json.slug_name crag_sector.user&.slug_name
end
json.history do
  json.extract! crag_sector, :created_at, :updated_at
end
