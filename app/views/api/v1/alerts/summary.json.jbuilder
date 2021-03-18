# frozen_string_literal: true

json.partial! 'api/v1/alerts/detail', alert: @alert
json.alertable do
  json.partial! 'api/v1/crags/short_detail', crag: @alert.alertable if @alert.alertable_type == 'Crag'
  json.partial! 'api/v1/crag_sectors/short_detail', crag_sector: @alert.alertable if @alert.alertable_type == 'CragSector'
  json.partial! 'api/v1/crag_routes/short_detail', crag_route: @alert.alertable if @alert.alertable_type == 'CragRoute'
end
