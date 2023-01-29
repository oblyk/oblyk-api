# frozen_string_literal: true

module Deactivable
  extend ActiveSupport::Concern

  included do
    scope :activated, -> { where('`deactivated_at` IS NULL OR `deactivated_at` > ?', Time.current) }
    scope :deactivated, -> { where.not(deactivated_at: nil) }
  end

  def deactivate!
    update_attribute :deactivated_at, Time.current
  end

  def activate!
    update_attribute :deactivated_at, nil
  end

  def deactivated?
    deactivated_at? && deactivated_at <= Time.current
  end

  def activated?
    !deactivated?
  end
end
