# frozen_string_literal: true

json.array! @areas do |area|
  json.partial! 'api/v1/areas/detail', area: area
end
