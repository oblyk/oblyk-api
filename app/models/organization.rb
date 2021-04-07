# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :organization_users
  has_many :users, through: :organization_users
  has_many :organization_gyms
  has_many :gyms, through: :organization_gyms

  ACCESS_DENIED_RIGHT = 'access_denied'
  READ_ONLY_RIGHT = 'read_only'
  NO_RESTRICTIONS_RIGHT = 'no_restrictions'

  RIGHT_STATUS_LIST = [ACCESS_DENIED_RIGHT, READ_ONLY_RIGHT, NO_RESTRICTIONS_RIGHT].freeze
  API_USAGE_LIST = %w[study personal commercial institutional].freeze

  before_validation :init_api_access_token
  before_validation :init_default_right

  validates :name, :email, :api_access_token, :api_usage_type, presence: true
  validates :name, uniqueness: true, on: :create
  validates :api_access_token, uniqueness: true, on: :create
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :api_usage_type, inclusion: { in: API_USAGE_LIST }
  validates :api_outdoor_right,
            :api_indoor_right,
            :api_community_right,
            inclusion: { in: RIGHT_STATUS_LIST }

  def refresh_api_access_token!
    update_attribute :api_access_token, SecureRandom.base36
  end

  private

  def init_api_access_token
    self.api_access_token ||= SecureRandom.base36
  end

  def init_default_right
    self.api_outdoor_right ||= READ_ONLY_RIGHT
    self.api_indoor_right ||= ACCESS_DENIED_RIGHT
    self.api_community_right ||= ACCESS_DENIED_RIGHT
  end
end
