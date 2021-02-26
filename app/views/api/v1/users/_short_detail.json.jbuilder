# frozen_string_literal: true

json.extract! user, :id, :uuid, :slug_name
json.full_name user.full_name
json.avatar_thumbnail_url user.avatar_thumbnail_url
