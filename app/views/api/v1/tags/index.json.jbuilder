# frozen_string_literal: true

json.array! @tags do |tag|
  json.partial! 'api/v1/tags/detail', tag: tag
end
