# frozen_string_literal: true

class User < ApplicationRecord
  include Geolocable

  has_secure_password
  has_one_attached :avatar
  has_many :follows, as: :followable
  has_many :followers, class_name: 'Follow', foreign_key: :user_id

  validates :first_name, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: true, on: :create

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
