# frozen_string_literal: true

json.array! @links do |link|
  json.partial! 'api/v1/links/detail', link: link
end
