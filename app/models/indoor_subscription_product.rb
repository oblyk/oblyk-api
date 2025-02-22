# frozen_string_literal: true

class IndoorSubscriptionProduct < ApplicationRecord
  validates :reference, :price_cents, presence: true
  validates :month_by_occurrence, inclusion: { in: [1, 3, 6, 12] }

  monetize :price_cents

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      reference: reference,
      order: order,
      recommended: recommended,
      month_by_occurrence: month_by_occurrence,
      for_gym_type: for_gym_type,
      price: {
        cents: price_cents,
        currency: price_currency
      }
    }
  end
end
