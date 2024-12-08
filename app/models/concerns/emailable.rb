# frozen_string_literal: true

module Emailable
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_email
  end

  private

  def normalize_email
    self.email = email&.strip&.downcase if has_attribute? :email
    self.requested_email = requested_email&.strip&.downcase if has_attribute? :requested_email
  end
end
