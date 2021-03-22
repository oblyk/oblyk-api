# frozen_string_literal: true

json.extract! article, :id, :name, :description, :views, :published_at

json.cover_url article.cover.attached? ? url_for(article.cover) : nil
json.thumbnail_url article.cover.attached? ? article.thumbnail_url : nil
