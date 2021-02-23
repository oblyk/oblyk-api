# frozen_string_literal: true

json.partial! 'api/v1/crags/short_detail', crag: crag

json.comment_count crag.comments.count
json.link_count crag.links.count
json.follow_count crag.follows.count
json.park_count crag.parks.count
json.alert_count crag.alerts.count
json.video_count crag.videos.count
json.photo_count crag.photos.count
json.versions_count crag.versions.count

json.guide_books do
  json.web_count crag.guide_book_webs.count
  json.pdf_count crag.guide_book_pdfs.count
  json.paper_count crag.guide_book_papers.count
end

json.creator do
  json.uuid crag.user&.uuid
  json.name crag.user&.full_name
  json.slug_name crag.user&.slug_name
end

json.sectors do
  json.array! crag.sectors do |sector|
    json.id sector.id
    json.name sector.name
  end
end

json.areas do
  json.array! crag.areas do |area|
    json.id area.id
    json.name area.name
    json.slug_name area.slug_name
  end
end

json.history do
  json.extract! crag, :created_at, :updated_at
end
