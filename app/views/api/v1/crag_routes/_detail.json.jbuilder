# frozen_string_literal: true

json.partial! 'api/v1/crag_routes/short_detail', crag_route: crag_route

json.sections crag_route.sections

json.tags do
  json.array! crag_route.tags do |tag|
    json.id tag.id
    json.name tag.name
  end
end
json.comment_count crag_route.comments.count
json.link_count crag_route.links.count
json.alert_count crag_route.alerts.count
json.video_count crag_route.videos.count
json.photo_count crag_route.photos.count

json.creator do
  json.id crag_route.user_id
  json.name crag_route.user&.full_name
end
json.history do
  json.extract! crag_route, :created_at, :updated_at
end
