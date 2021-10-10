# frozen_string_literal: true

class Subscribe < ApplicationRecord
  validates :email, presence: true

  before_validation :init_subscribed_at
  before_validation :init_error_counter

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: true, on: :create

  scope :sendable, -> { where('`subscribes`.`error` < 3').where(complained_at: nil) }

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      email: email,
      subscribed_at: subscribed_at,
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  private

  def init_subscribed_at
    self.subscribed_at ||= DateTime.current
  end

  def init_error_counter
    self.error ||= 0
  end
end
