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
              :north,
              :north_east,
              :east,
              :south_east,
              :south,
              :south_west,
              :west,
              :north_west
json.crag do
  json.id crag_sector.crag.id
  json.name crag_sector.crag.name
  json.slug_name crag_sector.crag.slug_name
  json.city crag_sector.crag.city
  json.country crag_sector.crag.country
  json.region crag_sector.crag.region
  json.photo do
    json.id crag_sector.crag&.photo&.id
    json.url url_for(crag_sector.crag.photo.picture) if crag_sector.crag&.photo
    json.thumbnail_url crag_sector.crag.photo.thumbnail_url if crag_sector.crag&.photo
  end
end
json.photo do
  json.id crag_sector.photo&.id
  json.url url_for(crag_sector.photo.picture) if crag_sector.photo
  json.thumbnail_url crag_sector.photo.thumbnail_url if crag_sector.photo
end
