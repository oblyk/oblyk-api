# frozen_string_literal: true

json.partial! 'api/v1/crag_routes/short_detail', crag_route: crag_route

json.versions_count crag_route.versions.count
json.sections crag_route.sections

json.ascent_comments do
  json.array! crag_route.public_ascents do |ascent|
    json.comment ascent.comment
    json.note ascent.note
    json.released_at ascent.released_at
    json.creator do
      json.id ascent.user_id
      json.slug_name ascent.user&.slug_name
      json.name ascent.user&.full_name
    end
  end
end
json.tags do
  json.array! crag_route.tags do |tag|
    json.id tag.id
    json.name tag.name
  end
end
json.link_count crag_route.links.count
json.alert_count crag_route.alerts.count

json.creator do
  json.id crag_route.user_id
  json.slug_name crag_route.user&.slug_name
  json.name crag_route.user&.full_name
end
json.history do
  json.extract! crag_route, :created_at, :updated_at
end
