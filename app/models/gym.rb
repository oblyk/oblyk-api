# frozen_string_literal: true

class Gym < ApplicationRecord
  include Geolocable
  include SoftDeletable
  include Searchable
  include Slugable
  include ParentFeedable
  include ActivityFeedable
  include AttachmentResizable
  include StripTagable

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
  ], if: proc { |_obj| ENV['PAPER_TRAIL'] == 'true' }

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
  has_many :gym_sectors, through: :gym_spaces
  has_many :gym_routes, through: :gym_sectors

  validates :logo, blob: { content_type: :image }, allow_nil: true
  validates :banner, blob: { content_type: :image }, allow_nil: true
  validates :name, :latitude, :longitude, :address, :country, :city, :big_city, presence: true

  def location
    [latitude, longitude]
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
        map_thumbnail_url: banner.present? ? banner_thumbnail_url : nil
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

  def banner_cropped_medium_url
    crop_attachment banner, '500x500'
  end

  def logo_large_url
    resize_attachment logo, '500x500'
  end

  def logo_thumbnail_url
    resize_attachment logo, '100x100'
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_gym") do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        description: description,
        email: email,
        phone_number: phone_number,
        web_site: web_site,
        latitude: latitude,
        longitude: longitude,
        code_country: code_country,
        country: country,
        city: city,
        big_city: big_city,
        region: region,
        address: address,
        postal_code: postal_code,
        sport_climbing: sport_climbing,
        bouldering: bouldering,
        pan: pan,
        fun_climbing: fun_climbing,
        training_space: training_space,
        administered: administered?,
        banner: banner.attached? ? banner_large_url : nil,
        banner_thumbnail_url: banner.attached? ? banner_thumbnail_url : nil,
        banner_cropped_url: banner ? banner_cropped_medium_url : nil,
        logo: logo.attached? ? logo_large_url : nil
      }
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        follow_count: follows.count,
        gym_grades_count: gym_grades.count,
        versions_count: versions.count,
        gym_spaces: gym_spaces.map(&:summary_to_json),
        creator: user&.summary_to_json,
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  private

  def search_indexes
    [
      { value: name },
      { value: city },
      { value: big_city }
    ]
  end
end
