# frozen_string_literal: true

json.partial! 'api/v1/articles/short_detail', article: article
json.body article.body
json.author_id article.author_id

json.author do
  json.partial! 'api/v1/authors/detail', author: article.author
end

json.crags do
  json.array! article.crags do |crag|
    json.partial! 'api/v1/crags/short_detail', crag: crag
  end
end

json.guide_book_papers do
  json.array! article.guide_book_papers do |guide_book_paper|
    json.partial! 'api/v1/guide_book_papers/short_detail', guide_book_paper: guide_book_paper
  end
end

json.history do
  json.extract! article, :created_at, :updated_at, :published_at
end
