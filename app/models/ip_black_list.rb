# frozen_string_literal: true

class IpBlackList < ApplicationRecord
  before_validation :init_blocked_at

  BLOCK_TIME = 30

  scope :currently_blocked, -> { where('block_expired_at <= NOW() OR block_expired_at IS NULL') }

  def blocked!(params)
    self.block_count ||= 0
    self.block_count += 1
    self.params_sent = params.to_s
    self.blocked_at = Time.current
    self.block_expired_at = Time.current + BLOCK_TIME.minutes
    save
  end

  private

  def init_blocked_at
    self.blocked_at = Time.current
    self.block_expired_at = Time.current + BLOCK_TIME.minutes
  end
end
