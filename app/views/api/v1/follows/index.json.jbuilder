# frozen_string_literal: true

json.array! @follows do |follow|
  json.partial! 'api/v1/follows/detail', follow: follow
end
