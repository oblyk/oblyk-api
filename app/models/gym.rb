# frozen_string_literal: true

class Gym < ApplicationRecord
  include Geolocable
  include SoftDeletable

  has_one_attached :logo
  belongs_to :user, optional: true
  has_many :follows, as: :followable
  has_many :gym_administrators

  validates :name, :latitude, :longitude, :address, :postal_code, :country, :city, :big_city, presence: true
end
