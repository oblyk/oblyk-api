# frozen_string_literal: true

json.array! @guide_book_papers do |guide_book_paper|
  json.partial! 'api/v1/guide_book_papers/detail', guide_book_paper: guide_book_paper
end
