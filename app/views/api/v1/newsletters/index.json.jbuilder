# frozen_string_literal: true

json.array! @newsletters do |newsletter|
  json.partial! 'api/v1/newsletters/detail', newsletter: newsletter
end
