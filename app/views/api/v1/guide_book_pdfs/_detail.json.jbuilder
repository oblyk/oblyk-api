# frozen_string_literal: true

json.extract! guide_book_pdf, :name, :description, :author, :publication_year
json.pdf_file url_for(guide_book_pdf.pdf_file)
json.crag do
  json.extract! guide_book_pdf.crag, :id, :name
end
json.creator do
  json.id guide_book_pdf.user_id
  json.name guide_book_pdf.user&.full_name
end
json.history do
  json.extract! guide_book_pdf, :created_at, :updated_at
end
