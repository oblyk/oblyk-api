# frozen_string_literal: true

json.extract! alert, :id, :description, :alert_type, :alerted_at
json.creator do
  json.uuid alert.user&.uuid
  json.name alert.user&.full_name
  json.slug_name alert.user&.slug_name
end
json.history do
  json.extract! alert, :created_at, :updated_at
end
