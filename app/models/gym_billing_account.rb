# frozen_string_literal: true

class GymBillingAccount < ApplicationRecord
  has_many :gyms
  validates :email, presence: true
  before_validation :set_uuid

  def summary_to_json
    {
      id: id,
      uuid: uuid,
      name: name,
      email: email
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  def create_strip_portal!(gym)
    return if customer_stripe_id.blank?

    Stripe.api_key = ENV['STRIPE_API_KEY']
    Stripe::BillingPortal::Session.create(
      {
        customer: customer_stripe_id,
        return_url: "#{gym.admin_app_path}/indoor-subscriptions"
      }
    )
  end

  private

  def set_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
