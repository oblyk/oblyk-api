# frozen_string_literal: true

class IndoorSubscription < ApplicationRecord
  has_many :indoor_subscription_gyms
  has_many :gyms, through: :indoor_subscription_gyms

  validates :start_date, presence: true
  validates :month_by_occurrence, inclusion: { in: [1, 3, 6, 12] }

  scope :active, -> { where('indoor_subscriptions.start_date <= :date AND (indoor_subscriptions.end_date IS NULL OR indoor_subscriptions.end_date >= :date)', date: Date.current) }

  WAITING_FIST_PAYMENT_STATUS = 'waiting_first_payment'
  PAYMENT_FAILED_STATUS = 'payment_failed'
  PAID_STATUS = 'paid'

  PAYMENT_STATUS_LIST = [WAITING_FIST_PAYMENT_STATUS, PAID_STATUS, PAYMENT_FAILED_STATUS].freeze

  def summary_to_json
    detail_to_json
  end

  def name
    gym_type = for_gym_type == 'club' ? 'Club' : 'Salle privée'

    "Abonnement #{gym_type} Pack Complet"
  end

  def active?
    start_date <= Date.current && (end_date.blank? || end_date >= Date.current)
  end

  def expired?
    !active?
  end

  def in_free_trial?
    return false if trial_end_date.blank?

    start_date <= Date.current && (end_date.blank? || end_date >= Date.current) && Date.current <= trial_end_date
  end

  def detail_to_json
    {
      id: id,
      name: name,
      for_gym_type: for_gym_type,
      month_by_occurrence: month_by_occurrence,
      start_date: start_date,
      end_date: end_date,
      trial_end_date: trial_end_date,
      cancelled_at: cancelled_at,
      active_subscription: active?,
      expired_subscription: expired?,
      have_stripe_subscription: subscription_stripe_id.present?,
      payment_link: payment_link,
      payment_status: payment_status,
      in_free_trial: in_free_trial?,
      gyms: gyms.map { |gym| { id: gym.id, name: gym.name, slug_name: gym.slug_name } }
    }
  end

  def create_payment_link!(indoor_subscription_product, gym, number_of_trials_days = nil)
    Stripe.api_key = ENV['STRIPE_API_KEY']

    # trial_period_days = nil
    # trial_period_days = (Date.current + 28.days).to_i if gym.indoor_subscriptions.count.zero?

    plan = Stripe::Plan.create(
      {
        amount: indoor_subscription_product.price_cents,
        currency: indoor_subscription_product.price_currency,
        interval: 'month',
        interval_count: indoor_subscription_product.month_by_occurrence,
        product: indoor_subscription_product.product_stripe_id
      }
    )

    subscription_data = {
      description: "Accéder à l'intégralité des fonctionnalités d'Oblyk indoor en illimité"
    }
    subscription_data[:trial_period_days] = number_of_trials_days if number_of_trials_days.present?

    payment_link = Stripe::PaymentLink.create(
      {
        line_items: [
          price: plan,
          quantity: 1
        ],
        after_completion: {
          type: 'redirect',
          redirect: {
            url: "#{gym.admin_app_path}/indoor-subscriptions"
          }
        },
        billing_address_collection: 'required',
        subscription_data: subscription_data,
        tax_id_collection: {
          enabled: true
        },
        metadata: {
          gym_billing_account_uuid: gym.gym_billing_account.uuid,
          indoor_subscription_id: id
        }
      }
    )

    self.payment_link_stipe_id = payment_link.id
    self.payment_link = "#{payment_link.url}?prefilled_email=#{gym.gym_billing_account.email}&client_reference_id=#{gym.gym_billing_account.uuid}"
    save!
  end

  def cancel!(canceled_at, cancel_at)
    already_cancel = cancelled_at.present?
    self.cancelled_at = canceled_at
    self.end_date = cancel_at
    save!
    update_gym_plans!

    return true if already_cancel

    IndoorSubscriptionMailer.with(indoor_subscription: self)
                            .cancel_indoor_subscription
                            .deliver_later
  end

  def un_cancel!
    already_un_cancel = end_date.blank?
    self.cancelled_at = nil
    self.end_date = nil
    save!
    update_gym_plans!

    return true if already_un_cancel

    IndoorSubscriptionMailer.with(indoor_subscription: self)
                            .un_cancel_indoor_subscription
                            .deliver_later
  end

  def update_gym_plans!
    indoor_subscription_gyms.each do |indoor_subscription_gym|
      indoor_subscription_gym.gym.update_plan!
    end
  end
end
