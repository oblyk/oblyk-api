# frozen_string_literal: true

json.array! @crags do |crag|
  json.partial! 'api/v1/crags/short_detail', crag: crag
end
