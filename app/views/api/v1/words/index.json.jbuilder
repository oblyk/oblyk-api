# frozen_string_literal: true

json.array! @words do |word|
  json.partial! 'api/v1/words/detail', word: word
end
