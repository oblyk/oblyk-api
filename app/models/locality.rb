# frozen_string_literal: true

class Locality < ApplicationRecord
  include Geolocable

  has_many :locality_users
  has_many :users, through: :locality_users

  validates :name, presence: true

  scope :with_partner_search, -> { where(partner_search_users_count: 1..) }
  scope :with_local_sharing, -> { where(local_sharing_users_count: 1..) }
  scope :with_climbers, -> { where('localities.local_sharing_users_count + localities.partner_search_users_count > 0') }

  def summary_to_json
    detail_to_json
  end

  def detail_to_json
    {
      id: id,
      name: name,
      code_country: code_country,
      region: region,
      partner_search_users_count: partner_search_users_count,
      local_sharing_users_count: local_sharing_users_count,
      distinct_users_count: distinct_users_count,
      latitude: latitude,
      longitude: longitude,
      country: I18n.t("code_country.#{code_country}"),
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  def to_geo_json
    {
      type: 'Feature',
      properties: {
        type: 'Locality',
        icon: 'locality',
        name: name,
        id: id,
        partner_search_users_count: partner_search_users_count,
        local_sharing_users_count: local_sharing_users_count,
        distinct_users_count: distinct_users_count
      },
      geometry: { type: 'Point', "coordinates": [Float(longitude), Float(latitude), 0.0] }
    }
  end

  def update_climber_counts!
    self.partner_search_users_count = LocalityUser.joins(:user)
                                                  .activated
                                                  .where(locality_id: id)
                                                  .where(partner_search: true)
                                                  .where('users.last_activity_at > ?', Date.current - 3.years)
                                                  .where(users: { partner_search: true })
                                                  .count
    self.local_sharing_users_count = LocalityUser.activated
                                                 .where(locality_id: id)
                                                 .where(local_sharing: true)
                                                 .count
    self.distinct_users_count = locality_users.activated.count
    save
  end
end
