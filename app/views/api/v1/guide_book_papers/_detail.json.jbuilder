# frozen_string_literal: true

json.partial! 'api/v1/guide_book_papers/short_detail', guide_book_paper: guide_book_paper

json.crags do
  json.array! guide_book_paper.crags do |crag|
    json.extract! crag, :id, :name
  end
end
json.creator do
  json.id guide_book_paper.user_id
  json.name guide_book_paper.user&.full_name
end
json.history do
  json.extract! guide_book_paper, :created_at, :updated_at
end
