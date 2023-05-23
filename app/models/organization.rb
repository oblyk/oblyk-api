# frozen_string_literal: true

class Organization < ApplicationRecord
  include Slugable

  has_secure_token :api_access_token

  mattr_accessor :current, instance_accessor: false

  has_many :organization_users
  has_many :users, through: :organization_users

  API_USAGE_LIST = %w[study personal commercial institutional ecosystem].freeze

  validates :name, :email, :api_usage_type, presence: true
  validates :name, uniqueness: true, on: :create
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :api_usage_type, inclusion: { in: API_USAGE_LIST }

  after_create :send_email_notification

  def refresh_api_access_token!
    regenerate_api_access_token
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_organization", expires_in: 28.days) do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        api_usage_type: api_usage_type,
        phone: phone,
        email: email,
        address: address,
        city: city,
        zipcode: zipcode,
        website: website,
        company_registration_number: company_registration_number
      }
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        organization_users: organization_users.map { |organization_user| { id: organization_user.id, user: organization_user.user.summary_to_json(with_avatar: false) } },
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  private

  def send_email_notification
    OrganizationMailer.with(
      organization_id: id,
      name: name,
      email: email,
      api_usage_type: api_usage_type
    ).new_organization.deliver_later
  end
end
