# frozen_string_literal: true

json.array! @guide_book_pdfs do |guide_book_pdf|
  json.partial! 'api/v1/guide_book_pdfs/detail', guide_book_pdf: guide_book_pdf
end
