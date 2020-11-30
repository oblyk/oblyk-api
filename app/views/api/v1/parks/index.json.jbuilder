# frozen_string_literal: true

json.array! @parks do |park|
  json.partial! 'api/v1/parks/detail', park: park
end
