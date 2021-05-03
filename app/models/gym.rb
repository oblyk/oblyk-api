# frozen_string_literal: true

class Gym < ApplicationRecord
  include Geolocable
  include SoftDeletable
  include Searchable
  include Slugable
  include ParentFeedable
  include ActivityFeedable
  include AttachmentResizable

  has_paper_trail only: %i[
    name
    description
    address
    postal_code
    code_country
    country
    city
    big_city
    region
    email
    phone_number
    web_site
    bouldering
    sport_climbing
    pan
    fun_climbing
    training_space
    latitude
    longitude
  ]

  has_one_attached :logo
  has_one_attached :banner
  belongs_to :user, optional: true
  has_many :follows, as: :followable
  has_many :videos, as: :viewable
  has_many :comments, as: :commentable
  has_many :feeds, as: :feedable
  has_many :gym_administrators
  has_many :gym_grades
  has_many :gym_spaces
  has_many :reports, as: :reportable

  validates :logo, blob: { content_type: :image }, allow_nil: true
  validates :banner, blob: { content_type: :image }, allow_nil: true
  validates :name, :latitude, :longitude, :address, :country, :city, :big_city, presence: true

  mapping do
    indexes :location, type: 'geo_point'
    indexes :name, analyzer: 'french'
    indexes :city, analyzer: 'french'
    indexes :big_city, analyzer: 'french'
  end

  def location
    [latitude, longitude]
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: %w[name city big_city],
            fuzziness: :auto
          }
        }
      }
    )
  end

  def summary_to_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/gyms/summary.json',
        assigns: { gym: self }
      )
    )
  end

  def to_geo_json
    {
      type: 'Feature',
      properties: {
        type: 'Gym',
        id: id,
        name: name,
        slug_name: slug_name,
        climbing_key: climbing_key,
        icon: "gym-marker-#{climbing_key}",
        localization: "#{city}, #{region}",
        bouldering: bouldering,
        sport_climbing: sport_climbing,
        pan: pan,
        fun_climbing: fun_climbing,
        training_space: training_space,
        map_thumbnail_url: banner.present? ? thumbnail_banner_url : nil
      },
      geometry: { type: 'Point', "coordinates": [Float(longitude), Float(latitude), 0.0] }
    }
  end

  def administered?
    assigned_at.present?
  end

  def administered!
    self.assigned_at ||= Time.current
    save
  end

  def climbing_key
    key = ''
    key += bouldering || pan ? '1' : '0'
    key += sport_climbing ? '1' : '0'
    key += fun_climbing ? '1' : '0'
    key
  end

  def banner_large_url
    resize_attachment banner, '1920x1920'
  end

  def banner_thumbnail_url
    resize_attachment banner, '300x300'
  end

  def logo_large_url
    resize_attachment banner, '500x500'
  end

  def logo_thumbnail_url
    resize_attachment banner, '100x100'
  end
end
