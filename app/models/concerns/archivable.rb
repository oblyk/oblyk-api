# frozen_string_literal: true

module Archivable
  extend ActiveSupport::Concern

  included do
    scope :unarchived, -> { where('`archived_at` IS NULL OR `archived_at` > ?', Time.current) }
    scope :archived, -> { where.not(archived_at: nil) }
  end

  def archive!
    update_attribute :archived_at, Time.current
  end

  def unarchive!
    update_attribute :archived_at, nil
  end

  def archived?
    archived_at? && archived_at <= Time.current
  end

  def unarchived?
    !archived?
  end
end
