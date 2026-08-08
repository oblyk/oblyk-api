# frozen_string_literal: true

module StripTagable
  include ActionView::Helpers::SanitizeHelper
  extend ActiveSupport::Concern

  DEFAULT_STRIPPABLE_COLUMNS = %i[
    requested_email justification code_country phone_number postal_code
    affiliation description definition first_name last_name big_city
    web_site openers country comment address source opener author
    editor region email body name city url ean alt
  ].freeze

  included do
    before_validation :strip_tag_columns
  end

  private

  def strip_tag_columns
    DEFAULT_STRIPPABLE_COLUMNS.each do |column|
      next unless has_attribute?(column)

      value = public_send(column)
      public_send("#{column}=", strip_tags(value)) if value
    end
  end
end
