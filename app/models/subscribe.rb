# frozen_string_literal: true

class Subscribe < ApplicationRecord
  validates :email, presence: true

  before_validation :init_subscribed_at

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: true, on: :create

  private

  def init_subscribed_at
    self.subscribed_at ||= DateTime.current
  end
end
