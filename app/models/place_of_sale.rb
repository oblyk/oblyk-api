# frozen_string_literal: true

class PlaceOfSale < ApplicationRecord
  include Geolocable
  include StripTagable

  belongs_to :user, optional: true
  belongs_to :guide_book_paper
  has_many :reports, as: :reportable

  validates :name, presence: true

  def location
    [latitude, longitude]
  end

  def to_geo_json(minimalistic: false)
    features = {
      type: 'Feature',
      properties: {
        type: 'PlaceOfSale',
        id: id,
        guide_book_paper_id: guide_book_paper_id,
        icon: 'place-of-sale-marker'
      },
      geometry: { type: 'Point', "coordinates": [Float(longitude), Float(latitude), 0.0] }
    }
    unless minimalistic
      features[:properties].merge!(
        {
          name: name,
          description: description,
          url: url,
          localization: "#{address} #{code_country} #{city} (#{country}) "
        }
      )
    end
    features
  end

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      name: name,
      url: url,
      description: description,
      latitude: latitude,
      longitude: longitude,
      code_country: code_country,
      country: country,
      postal_code: postal_code,
      city: city,
      region: region,
      address: address,
      guide_book_paper_id: guide_book_paper_id,
      creator: user&.summary_to_json(with_avatar: false),
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end
end
