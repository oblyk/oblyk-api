# frozen_string_literal: true

json.extract! crag,
              :id,
              :name,
              :rain,
              :sun

json.rocks crag.rocks

json.climbing_type do
  json.extract! crag,
                :sport_climbing,
                :bouldering,
                :multi_pitch,
                :trad_climbing,
                :aid_climbing,
                :deep_water,
                :via_ferrata
end
json.orientation do
  json.extract! crag,
                :north,
                :north_east,
                :east,
                :south_east,
                :south,
                :south_west,
                :west,
                :north_west
end
json.seasons do
  json.extract! crag,
                :summer,
                :autumn,
                :winter,
                :spring
end
json.localization do
  json.extract! crag,
                :latitude,
                :longitude,
                :code_country,
                :country,
                :city,
                :region
end

json.comment_count crag.comments.count
json.link_count crag.links.count
json.follow_count crag.follows.count
json.park_count crag.parks.count
json.alert_count crag.alerts.count
json.video_count crag.videos.count

json.guide_books do
  json.web_count crag.guide_book_webs.count
end

json.creator do
  json.id crag.user_id
  json.name crag.user&.full_name
end
json.sectors do
  json.array! crag.sectors do |sector|
    json.id sector.id
    json.name sector.name
  end
end
json.routes_figures do
  json.count crag.crag_routes_count
  json.grade do
    json.min_value crag.min_grade_value
    json.max_value crag.max_grade_value
    json.max_text crag.max_grade_text
    json.min_text crag.min_grade_text
  end
end
json.history do
  json.extract! crag, :created_at, :updated_at
end
