# frozen_string_literal: true

json.array! @guide_book_webs do |guide_book_web|
  json.partial! 'api/v1/guide_book_webs/detail', guide_book_web: guide_book_web
end
