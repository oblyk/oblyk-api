# frozen_string_literal: true

class Notification < ApplicationRecord
  include Readable

  NOTIFIABLE_TYPE_LIST = %w[User Article ConversationMessage].freeze
  NOTIFICATION_TYPE_LIST = %w[
    new_message
    new_follower
    subscribe_accepted
    request_for_follow_up
    new_article
  ].freeze

  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  validates :notification_type, presence: true
  validates :notifiable_type, inclusion: { in: NOTIFIABLE_TYPE_LIST.freeze }
  validates :notification_type, inclusion: { in: NOTIFICATION_TYPE_LIST }

  default_scope { order(posted_at: :desc) }

  before_validation :set_posted_at

  private

  def set_posted_at
    self.posted_at ||= Time.current
  end
end
