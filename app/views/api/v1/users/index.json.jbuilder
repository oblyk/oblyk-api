# frozen_string_literal: true

json.array! @users do |user|
  json.partial! 'api/v1/users/short_detail', user: user
end
