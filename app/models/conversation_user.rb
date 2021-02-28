# frozen_string_literal: true

class ConversationUser < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  def read!
    update_attribute(:last_read_at, DateTime.current)
  end
end
