# frozen_string_literal: true

json.extract! word,
              :id,
              :name,
              :slug_name,
              :definition
json.versions_count word.versions.length
json.creator do
  json.uuid word.user&.uuid
  json.name word.user&.full_name
  json.slug_name word.user&.slug_name
end
json.history do
  json.extract! word, :created_at, :updated_at
end
