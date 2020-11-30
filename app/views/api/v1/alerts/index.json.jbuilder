# frozen_string_literal: true

json.array! @alerts do |alert|
  json.partial! 'api/v1/alerts/detail', alert: alert
end
