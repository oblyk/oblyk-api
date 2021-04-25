# frozen_string_literal: true

json.array! @notifications do |notification|
  json.partial! 'api/v1/notifications/detail', notification: notification
end
