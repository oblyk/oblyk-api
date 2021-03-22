# frozen_string_literal: true

json.extract! author, :id, :name, :description

json.cover_url author.cover.attached? ? url_for(author.cover) : nil
json.thumbnail_url author.cover.attached? ? author.thumbnail_url : nil
