# frozen_string_literal: true

json.extract! crag_route,
              :id,
              :name,
              :slug_name,
              :height,
              :open_year,
              :opener,
              :climbing_type,
              :sections_count,
              :max_bolt,
              :note,
              :note_count,
              :ascents_count,
              :photos_count,
              :videos_count,
              :comments_count,
              :votes
json.grade_to_s crag_route.grade_to_s
json.grade_gap do
  json.extract! crag_route,
                :max_grade_value,
                :min_grade_value,
                :max_grade_text,
                :min_grade_text
end
json.crag_sector do
  json.id crag_route.crag_sector&.id
  json.name crag_route.crag_sector&.name
  json.slug_name crag_route.crag_sector&.slug_name
  json.photo do
    json.id crag_route.crag_sector&.photo&.id
    json.url url_for(crag_route.crag_sector.photo.picture) if crag_route.crag_sector&.photo
    json.thumbnail_url crag_route.crag_sector.photo.thumbnail_url if crag_route.crag_sector&.photo
  end
end
json.crag do
  json.id crag_route.crag.id
  json.name crag_route.crag.name
  json.slug_name crag_route.crag.slug_name
  json.country crag_route.crag.country
  json.region crag_route.crag.region
  json.city crag_route.crag.city
  json.photo do
    json.id crag_route.crag&.photo&.id
    json.url url_for(crag_route.crag.photo.picture) if crag_route.crag&.photo
    json.thumbnail_url crag_route.crag.photo.thumbnail_url if crag_route.crag&.photo
  end
end

json.photo do
  json.id crag_route.photo&.id
  json.url url_for(crag_route.photo.picture) if crag_route.photo
  json.thumbnail_url crag_route.photo.thumbnail_url if crag_route.photo
end
