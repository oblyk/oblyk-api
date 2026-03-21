# frozen_string_literal: true

class CommentSerializer < BaseSerializer
  belongs_to :user
  has_one :commentable, polymorphic: true

  attributes :id,
             :body,
             :likes_count,
             :comments_count,
             :reply_to_comment_id,
             :commentable_type,
             :commentable_id,
             :moderated_at

  attribute :body do |object|
    object.moderated_at.blank? ? object.body : nil
  end

  attribute :moderated do |object|
    object.moderated_at.present?
  end

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end
end
