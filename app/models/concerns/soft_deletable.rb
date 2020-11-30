# frozen_string_literal: true

module SoftDeletable
  extend ActiveSupport::Concern

  included do
    default_scope { where("`#{table_name}`.`deleted_at` IS NULL OR `#{table_name}`.`deleted_at` > ?", Time.current) }
    scope :deleted, -> { where.not(deleted_at: nil) }
  end

  def deleted?
    deleted_at? && deleted_at <= Time.current
  end

  def delete
    update_attribute :deleted_at, Time.current
  end

end
