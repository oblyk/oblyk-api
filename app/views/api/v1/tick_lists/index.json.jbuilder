# frozen_string_literal: true

json.array! @tick_lists do |tick_list|
  json.partial! 'api/v1/tick_lists/detail', tick_list: tick_list
end
