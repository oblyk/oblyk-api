# frozen_string_literal: true

class Park < ApplicationRecord
  include Geolocable

  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable

  validates :latitude, :longitude, presence: true
end
