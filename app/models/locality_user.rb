# frozen_string_literal: true

class LocalityUser < ApplicationRecord
  include Deactivable

  belongs_to :locality
  belongs_to :user

  attr_accessor :latitude, :longitude

  validates :radius, numericality: { greater_than: 0, less_than_or_equal_to: 100 }

  before_validation :set_radius

  after_save :update_locality!

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      description: description,
      partner_search: partner_search,
      local_sharing: local_sharing,
      radius: radius,
      deactivated_at: deactivated_at,
      user: {
        id: user.id,
        uuid: user.uuid,
        slug_name: user.slug_name,
        first_name: user.first_name
      },
      locality_id: locality_id,
      locality: locality.summary_to_json
    }
  end

  def local_to_json
    {
      locality_user: {
        description: description ? Markdown.new(description, :hard_wrap).to_html.html_safe : '',
        partner_search: partner_search,
        local_sharing: local_sharing,
        created_at: created_at
      },
      locality: locality.summary_to_json,
      user: user.local_climber_to_json
    }
  end

  def create_by_reverse_geocoding!
    reverse_place = OpenStreetMapApi.reverse_geocoding(latitude, longitude)

    place = reverse_place['address']

    if place.blank?
      errors.add(:base, I18n.t('activerecord.errors.messages.invalid'))
      return false
    end

    city = place['city'] || place['town'] || place['village'] || place['municipality']
    code_country = place['country_code']
    region = place['state_district'] || place['county'] || place['state']

    existing_locality = Locality.where(name: city).geo_search(latitude, longitude, 50).first

    if existing_locality
      already_in_this_locality = LocalityUser.find_by user: user, locality: existing_locality
      if already_in_this_locality
        errors.add(:base, I18n.t('activerecord.errors.messages.exist'))
        return false
      end
    end

    self.locality = (existing_locality || Locality.new(
      name: city,
      code_country: code_country,
      region: region,
      latitude: reverse_place['lat'],
      longitude: reverse_place['lon']
    ))
    save
  end

  private

  def update_locality!
    locality.update_climber_counts!
  end

  def set_radius
    self.radius ||= 20
  end
end
