# frozen_string_literal: true

json.array! @approaches do |approach|
  json.partial! 'api/v1/approaches/detail', approach: approach
end
