# frozen_string_literal: true

class Park < ApplicationRecord
  include Geolocable

  belongs_to :user, optional: true
  belongs_to :crag
  has_many :reports, as: :reportable

  validates :latitude, :longitude, presence: true

  def location
    [latitude, longitude]
  end

  def to_geo_json
    {
      type: 'Feature',
      properties: {
        type: 'Park',
        id: id,
        description: description,
        icon: 'park-marker',
        crag: {
          id: crag.id,
          name: crag.name,
          slug_name: crag.slug_name
        }
      },
      geometry: { type: 'Point', "coordinates": [Float(longitude), Float(latitude), 0.0] }
    }
  end
end
