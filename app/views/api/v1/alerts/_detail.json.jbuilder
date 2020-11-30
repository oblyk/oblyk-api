# frozen_string_literal: true

json.extract! alert, :id, :description, :alert_type, :alerted_at
json.creator do
  json.id alert.user_id
  json.name alert.user&.full_name
end
json.history do
  json.extract! alert, :created_at, :updated_at
end
