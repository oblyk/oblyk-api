# frozen_string_literal: true

json.partial! 'api/v1/photos/detail', photo: @photo
json.illustrable do
  json.partial! 'api/v1/crags/short_detail', crag: @photo.illustrable if @photo.illustrable_type == 'Crag'
  json.partial! 'api/v1/crag_sectors/short_detail', crag_sector: @photo.illustrable if @photo.illustrable_type == 'CragSector'
  json.partial! 'api/v1/crag_routes/short_detail', crag_route: @photo.illustrable if @photo.illustrable_type == 'CragRoute'
end
