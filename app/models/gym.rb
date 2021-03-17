# frozen_string_literal: true

class Gym < ApplicationRecord
  include Geolocable
  include SoftDeletable
  include Searchable
  include Slugable
  include ActivityFeedable

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

  mapping do
    indexes :location, type: 'geo_point'
  end

  has_one_attached :logo
  has_one_attached :banner
  belongs_to :user, optional: true
  has_many :follows, as: :followable
  has_many :feeds, as: :feedable
  has_many :gym_administrators
  has_many :gym_grades
  has_many :gym_spaces
  has_many :reports, as: :reportable

  validates :logo, blob: { content_type: :image }, allow_nil: true
  validates :banner, blob: { content_type: :image }, allow_nil: true
  validates :name, :latitude, :longitude, :address, :postal_code, :country, :city, :big_city, presence: true

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

  def thumbnail_banner_url
    Rails.application.routes.url_helpers.rails_representation_url(banner.variant(resize: '300x300').processed, only_path: true)
  end

  def feed_parent_id
    id
  end

  def feed_parent_type
    self.class.name
  end
end
