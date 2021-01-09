# frozen_string_literal: true

json.array! @subscribes do |subscribe|
  next if subscribe.followable_type == 'User'

  json.followable_type subscribe.followable_type
  json.followable_id subscribe.followable_id
  json.followable_object do
    json.partial! "api/v1/#{subscribe.followable_type.downcase.pluralize}/short_detail", subscribe.followable_type.downcase.to_sym => subscribe.followable
  end
end
