# frozen_string_literal: true

json.extract! author, :id, :name, :description, :user_id

json.cover_url author.cover.attached? ? author.cover_large_url : nil
json.thumbnail_url author.cover.attached? ? author.cover_thumbnail_url : nil
