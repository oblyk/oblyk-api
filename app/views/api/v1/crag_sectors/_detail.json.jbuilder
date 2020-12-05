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

json.comment_count crag.comments.count
json.link_count crag.links.count
json.follow_count crag.follows.count
json.alert_count crag.alerts.count
json.photo_count crag.photos.count

json.creator do
  json.id crag_sector.user_id
  json.name crag_sector.user&.full_name
end
json.history do
  json.extract! crag_sector, :created_at, :updated_at
end
