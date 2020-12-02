# frozen_string_literal: true

json.array! @conversations do |conversation|
  json.partial! 'api/v1/conversations/detail', conversation: conversation
end
