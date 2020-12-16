# frozen_string_literal: true

json.extract! crag_sector,
              :id,
              :crag_id,
              :name,
              :description,
              :rain,
              :sun
json.orientation do
  json.extract! crag_sector,
                :north,
                :north_east,
                :east,
                :south_east,
                :south,
                :south_west,
                :west,
                :north_west
end
json.localization do
  json.extract! crag_sector,
                :latitude,
                :longitude
end
json.routes_figures do
  json.count crag_sector.crag_routes_count
  json.grade do
    json.min_value crag_sector.min_grade_value
    json.max_value crag_sector.max_grade_value
    json.max_text crag_sector.max_grade_text
    json.min_text crag_sector.min_grade_text
  end
end
