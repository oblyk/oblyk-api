# frozen_string_literal: true

class ConversationMessage < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  before_validation :init_posted_at

  validates :body, presence: true

  private

  def init_posted_at
    self.posted_at ||= Time.current
  end
end
