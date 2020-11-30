# frozen_string_literal: true

json.array! @comments do |comment|
  json.partial! 'api/v1/comments/detail', comment: comment
end
