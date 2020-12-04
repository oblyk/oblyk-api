# frozen_string_literal: true

json.extract! guide_book_web, :name, :url
json.crag do
  json.extract! guide_book_web.crag, :id, :name
end
json.creator do
  json.id guide_book_web.user_id
  json.name guide_book_web.user&.full_name
end
json.history do
  json.extract! guide_book_web, :created_at, :updated_at
end
