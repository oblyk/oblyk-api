# frozen_string_literal: true

json.extract! subscribe, :email, :subscribed_at
json.history do
  json.extract! subscribe, :created_at, :updated_at
end
