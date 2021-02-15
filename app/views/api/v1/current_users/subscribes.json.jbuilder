# frozen_string_literal: true

json.array! @subscribes do |subscribe|
  next if subscribe.followable_type == 'User'

  json.followable_type subscribe.followable_type
  json.followable_id subscribe.followable_id
  json.followable_object do
    json.partial! "api/v1/#{subscribe.followable_type.pluralize.underscore}/short_detail", subscribe.followable_type.underscore.to_sym => subscribe.followable
  end
end
