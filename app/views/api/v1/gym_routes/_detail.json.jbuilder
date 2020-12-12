# frozen_string_literal: true

json.partial! 'api/v1/gym_routes/short_detail', gym_route: gym_route
json.tags do
  json.array! gym_route.tags do |tag|
    json.id tag.id
    json.name tag.name
  end
end
json.video_count gym_route.videos.count

json.history do
  json.extract! gym_route, :created_at, :updated_at
end
