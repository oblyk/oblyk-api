# frozen_string_literal: true

json.array! @videos do |video|
  json.partial! 'api/v1/videos/detail', video: video
end
