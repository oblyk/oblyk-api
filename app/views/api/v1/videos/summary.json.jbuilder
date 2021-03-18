# frozen_string_literal: true

json.partial! 'api/v1/videos/detail', video: @video
json.viewable do
  json.partial! 'api/v1/crags/short_detail', crag: @video.viewable if @video.viewable_type == 'Crag'
  json.partial! 'api/v1/crag_routes/short_detail', crag_route: @video.viewable if @video.viewable_type == 'CragRoute'
end
