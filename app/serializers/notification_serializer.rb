# frozen_string_literal: true

class NotificationSerializer
  include JSONAPI::Serializer

  belongs_to :notifiable, polymorphic: true

  attributes :id,
             :notification_type,
             :notifiable_type,
             :notifiable_id,
             :posted_at,
             :read_at,
             :name,
             :app_path

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
