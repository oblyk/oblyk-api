# frozen_string_literal: true

json.partial! 'api/v1/guide_book_papers/short_detail', guide_book_paper: guide_book_paper

json.photos_count guide_book_paper.all_photos_count
json.crags_count guide_book_paper.crags.count
json.links_count guide_book_paper.links.count
json.versions_count guide_book_paper.versions.count
json.articles_count guide_book_paper.articles_count

json.crags do
  json.array! guide_book_paper.crags do |crag|
    json.extract! crag, :id, :name
  end
end
json.creator do
  json.uuid guide_book_paper.user&.uuid
  json.name guide_book_paper.user&.full_name
  json.slug_name guide_book_paper.user&.slug_name
end
json.history do
  json.extract! guide_book_paper, :created_at, :updated_at
end
