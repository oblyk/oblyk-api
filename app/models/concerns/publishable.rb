# frozen_string_literal: true

module Publishable
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where.not(published_at: nil) }
    scope :unpublished, -> { where(published_at: nil) }
  end

  def published?
    published_at?
  end

  def unpublished?
    published_at.blank?
  end

  def publish!
    update_attribute :published_at, Time.current
  end

  def unpublish!
    update_attribute :published_at, nil
  end

end
