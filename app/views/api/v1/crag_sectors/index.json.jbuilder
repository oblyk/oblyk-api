# frozen_string_literal: true

json.array! @crag_sectors do |crag_sector|
  json.partial! 'api/v1/crag_sectors/short_detail', crag_sector: crag_sector
end
