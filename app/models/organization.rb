# frozen_string_literal: true

class Organization < ApplicationRecord
  has_secure_token :api_access_token

  mattr_accessor :current, instance_accessor: false

  has_many :organization_users
  has_many :users, through: :organization_users

  API_USAGE_LIST = %w[study personal commercial institutional ecosystem].freeze

  validates :name, :email, :api_usage_type, presence: true
  validates :name, uniqueness: true, on: :create
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :api_usage_type, inclusion: { in: API_USAGE_LIST }

  def refresh_api_access_token!
    regenerate_api_access_token
  end
end
