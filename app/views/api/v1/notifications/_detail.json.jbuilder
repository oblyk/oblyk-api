# frozen_string_literal: true

json.extract! notification, :id, :notification_type, :notifiable_type, :notifiable_id, :posted_at, :read_at
json.notifiable_object do
  json.partial! 'api/v1/users/short_detail', user: notification.notifiable if notification.notifiable_type == 'User'
  json.partial! 'api/v1/conversation_messages/detail', conversation_message: notification.notifiable if notification.notifiable_type == 'ConversationMessage'
  json.partial! 'api/v1/articles/short_detail', article: notification.notifiable if notification.notifiable_type == 'Article'
end
json.parent_object do
  json.partial! 'api/v1/users/short_detail', user: notification.notifiable.user if notification.notifiable_type == 'ConversationMessage'
end

json.history do
  json.extract! notification, :created_at, :updated_at
end
