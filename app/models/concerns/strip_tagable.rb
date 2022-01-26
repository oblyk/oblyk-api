# frozen_string_literal: true

module StripTagable
  include ActionView::Helpers::SanitizeHelper
  extend ActiveSupport::Concern

  included do
    before_validation :strip_tag_column if has_attribute?(:description)
    before_validation :strip_tag_column if has_attribute?(:definition)
    before_validation :strip_tag_column if has_attribute?(:comment)
    before_validation :strip_tag_column if has_attribute?(:body)
  end

  private

  def strip_tag_column
    self.description = strip_tags(description) if has_attribute?(:description) && description
    self.definition = strip_tags(definition) if has_attribute?(:definition) && definition
    self.comment = strip_tags(comment) if has_attribute?(:comment) && comment
    self.body = strip_tags(body) if has_attribute?(:body) && body
  end
end
