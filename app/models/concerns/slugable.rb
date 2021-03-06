# frozen_string_literal: true

module Slugable
  extend ActiveSupport::Concern

  included do
    before_validation :init_slug_name if has_attribute?(:slug_name)
  end

  private

  def init_slug_name
    self.slug_name ||= name&.parameterize.presence || self.class.name.downcase if has_attribute?(:name)
    self.slug_name ||= first_name&.parameterize.presence || self.class.name.downcase if has_attribute?(:first_name)
  end
end
