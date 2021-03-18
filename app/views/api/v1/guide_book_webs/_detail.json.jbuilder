# frozen_string_literal: true

json.extract! guide_book_web, :id, :name, :url, :publication_year
json.crag do
  json.extract! guide_book_web.crag, :id, :name, :slug_name
end
json.creator do
  json.uuid guide_book_web.user&.uuid
  json.name guide_book_web.user&.full_name
  json.slug_name guide_book_web.user&.slug_name
end
json.history do
  json.extract! guide_book_web, :created_at, :updated_at
end
