# frozen_string_literal: true

class Comment < ApplicationRecord
  include StripTagable

  belongs_to :user, optional: true
  belongs_to :reply_to_comment, class_name: 'Comment', optional: true
  belongs_to :commentable, polymorphic: true, counter_cache: :comments_count, touch: true
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :reply_to_comments, class_name: 'Comment', foreign_key: :reply_to_comment_id, dependent: :destroy

  before_validation :normalize_blank_values

  validates :body, presence: true
  validates :commentable_type, inclusion: { in: %w[Crag CragSector CragRoute GuideBookPaper Area Gym GymRoute Article Comment Ascent].freeze }

  after_create :create_notification!
  after_destroy :destroy_notification!

  def summary_to_json
    {
      id: id,
      body: moderated_at.blank? ? body : nil,
      creator: user&.summary_to_json(with_avatar: false),
      likes_count: likes_count,
      comments_count: comments_count,
      reply_to_comment_id: reply_to_comment_id,
      commentable_type: commentable_type,
      commentable_id: commentable_id,
      moderated_at: moderated_at,
      moderated: moderated_at.present?,
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        commentable: commentable.summary_to_json
      }
    )
  end

  private

  def normalize_blank_values
    self.body = body&.strip
    self.body = nil if body.blank?
  end

  def create_notification!
    return unless commentable_type == 'Comment'

    Notification.create(
      notification_type: 'new_reply',
      notifiable_type: 'Comment',
      notifiable_id: id,
      user: commentable.user
    )
  end

  def destroy_notification!
    return unless commentable_type == 'Comment'

    notification = Notification.find_by(
      notification_type: 'new_reply',
      notifiable_type: 'Comment',
      notifiable_id: id,
      user: commentable.user
    )
    notification&.destroy
  end
end
