# frozen_string_literal: true

json.extract! newsletter, :id, :slug_name, :name, :body, :sent_at
json.sent newsletter.sent?

json.history do
  json.extract! newsletter, :created_at, :updated_at, :sent_at
end
