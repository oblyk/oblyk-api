# frozen_string_literal: true

json.array! @articles do |article|
  json.partial! 'api/v1/articles/detail', article: article
end
