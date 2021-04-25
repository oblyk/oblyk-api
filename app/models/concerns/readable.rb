# frozen_string_literal: true

module Readable
  extend ActiveSupport::Concern

  included do
    scope :read, -> { where.not(read_at: nil) }
    scope :unread, -> { where(read_at: nil) }
  end

  def read?
    read_at?
  end

  def unread?
    read_at.blank?
  end

  def read!
    update_attribute :read_at, Time.current
  end

  def unread!
    update_attribute :read_at, nil
  end
end
