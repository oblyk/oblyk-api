# frozen_string_literal: true

class StripeCheckoutSession < ApplicationRecord
  def processed?
    processed_at.present?
  end

  def processed!
    self.processed_at = Time.zone.now
    save!
  end
end
