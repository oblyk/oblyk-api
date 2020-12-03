# frozen_string_literal: true

json.array! @subscribes do |subscribe|
  json.partial! 'api/v1/subscribes/detail', subscribe: subscribe
end
