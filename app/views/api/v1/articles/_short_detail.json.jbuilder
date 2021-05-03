# frozen_string_literal: true

json.extract! article, :id, :slug_name, :name, :description, :views, :comments_count, :published_at
json.published article.published?

json.cover_url article.cover.attached? ? article.cover_large_url : nil
json.thumbnail_url article.cover.attached? ? article.cover_thumbnail_url : nil
