# frozen_string_literal: true

json.extract! guide_book_pdf, :id, :name, :description, :author, :publication_year
json.pdf_file url_for(guide_book_pdf.pdf_file)
json.crag do
  json.extract! guide_book_pdf.crag, :id, :name
end
json.creator do
  json.uuid guide_book_pdf.user&.uuid
  json.name guide_book_pdf.user&.full_name
  json.slug_name guide_book_pdf.user&.slug_name
end
json.history do
  json.extract! guide_book_pdf, :created_at, :updated_at
end
