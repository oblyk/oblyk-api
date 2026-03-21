# frozen_string_literal: true

class ConversationMessageSerializer < BaseSerializer
  belongs_to :user

  attributes :id,
             :conversation_id,
             :body,
             :posted_at

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
