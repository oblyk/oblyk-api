# frozen_string_literal: true

class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :token, :user_agent, presence: true
  validates :token, uniqueness: true
  validates :token, uniqueness: { scope: :user_agent }

  def unused_token
    token_attempt = SecureRandom.base36
    unique = false
    oops = 0

    until unique
      oops += 1
      break if oops > 1000

      unique = !(RefreshToken.exists? token: token_attempt)
    end

    return unless unique

    self.token = token_attempt
  end
end
