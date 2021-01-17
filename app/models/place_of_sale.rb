# frozen_string_literal: true

class PlaceOfSale < ApplicationRecord
  include Geolocable

  belongs_to :user, optional: true
  belongs_to :guide_book_paper
  has_many :reports, as: :reportable

  validates :name, presence: true

  def to_geo_json
    {
      type: 'Feature',
      properties: {
        type: 'PlaceOfSale',
        id: id,
        name: name,
        description: description,
        url: url,
        icon: 'place-of-sale-marker',
        localization: "#{address} #{code_country} #{city} (#{country}) ",
      },
      geometry: { type: 'Point', "coordinates": [Float(longitude), Float(latitude), 0.0] }
    }
  end
end
