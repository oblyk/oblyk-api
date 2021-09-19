# frozen_string_literal: true

json.extract! crag_sector,
              :id,
              :crag_id,
              :name,
              :slug_name,
              :description,
              :rain,
              :sun,
              :latitude,
              :longitude,
              :elevation,
              :north,
              :north_east,
              :east,
              :south_east,
              :south,
              :south_west,
              :west,
              :north_west
json.routes_figures do
  json.count crag_sector.crag_routes_count
  json.grade do
    json.min_value crag_sector.min_grade_value
    json.max_value crag_sector.max_grade_value
    json.max_text crag_sector.max_grade_text
    json.min_text crag_sector.min_grade_text
  end
end
json.crag do
  json.id crag_sector.crag.id
  json.name crag_sector.crag.name
  json.slug_name crag_sector.crag.slug_name
  json.city crag_sector.crag.city
  json.country crag_sector.crag.country
  json.region crag_sector.crag.region
  json.photo do
    json.id crag_sector.crag&.photo&.id
    json.url crag_sector.crag.photo.large_url if crag_sector.crag&.photo
    json.thumbnail_url crag_sector.crag.photo.thumbnail_url if crag_sector.crag&.photo
  end
end
json.photo do
  json.id crag_sector.photo&.id
  json.url crag_sector.photo.large_url if crag_sector.photo
  json.thumbnail_url crag_sector.photo.thumbnail_url if crag_sector.photo
end
