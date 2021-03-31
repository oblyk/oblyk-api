# frozen_string_literal: true

class User < ApplicationRecord
  include Searchable
  include Geolocable
  include Slugable
  include ParentFeedable

  mattr_accessor :current, instance_accessor: false

  has_secure_password
  has_one_attached :avatar
  has_one_attached :banner
  has_many :follows, as: :followable
  has_many :subscribes, class_name: 'Follow', foreign_key: :user_id
  has_many :conversation_messages
  has_many :conversation_users
  has_many :conversations, through: :conversation_users
  has_many :tick_lists
  has_many :ticked_crag_routes, through: :tick_lists, source: :crag_route
  has_many :photos
  has_many :videos
  has_many :gym_administrators
  has_many :gyms, through: :gym_administrators
  has_many :reports, as: :reportable
  has_many :ascent_crag_routes
  has_many :ascended_crag_routes, through: :ascent_crag_routes, source: :crag_route
  has_many :ascended_crags, through: :ascended_crag_routes, source: :crag
  has_many :ascent_gym_routes
  has_many :ascent_users

  before_validation :set_uuid
  before_validation :last_activity_at
  before_validation :init_partner_search_activated_at

  validates :first_name, :email, :uuid, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: true, on: :create
  validates :uuid, uniqueness: true, on: :create
  validates :genre, inclusion: { in: %w[male female] }, allow_blank: true
  validates :language, inclusion: { in: %w[fr en] }

  validates :partner_latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_blank: true
  validates :partner_longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_blank: true

  validates :avatar, blob: { content_type: :image }, allow_nil: true
  validates :banner, blob: { content_type: :image }, allow_nil: true

  scope :partner_geolocable, -> { where(partner_search: true).where.not(partner_latitude: nil).where.not(partner_longitude: nil) }

  mapping do
    indexes :partner_location, type: 'geo_point'
    indexes :location, type: 'geo_point'
  end

  def location
    [latitude, longitude]
  end

  def partner_location
    [partner_latitude, partner_longitude]
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: %w[first_name last_name],
            fuzziness: :auto
          }
        }
      }
    )
  end

  def send_reset_password_instructions
    token = SecureRandom.base36
    self.reset_password_token = token
    self.reset_password_token_expired_at = Time.zone.now + 30.minutes
    save!

    UserMailer.with(user: self, token: token).reset_password.deliver_now
  end

  def subscribes_to_a
    json_follows = []
    subscribes.each do |follow|
      json_follows << {
        id: follow.id,
        followable_type: follow.followable_type,
        followable_id: follow.followable_id,
        accepted: follow.accepted?
      }
    end
    json_follows
  end

  def ascent_crag_routes_to_a
    json_ascents = []
    ascent_crag_routes.each do |ascent|
      json_ascents << {
        crag_route_id: ascent.crag_route_id,
        ascent_status: ascent.ascent_status,
        released_at: ascent.released_at
      }
    end
    json_ascents
  end

  def tick_list_to_a
    tick_lists.pluck(:crag_route_id)
  end

  def activity!
    update_attribute(:last_activity_at, DateTime.current)
  end

  def to_partner_geo_json
    {
      type: 'Feature',
      properties: {
        type: 'PartnerUser',
        uuid: uuid,
        full_name: full_name,
        slug_name: slug_name,
        description: description,
        date_of_birth: date_of_birth,
        genre: genre,
        icon: 'partner-user',
        sport_climbing: sport_climbing,
        bouldering: bouldering,
        multi_pitch: multi_pitch,
        trad_climbing: trad_climbing,
        aid_climbing: aid_climbing,
        deep_water: deep_water,
        via_ferrata: via_ferrata,
        pan: pan,
        avatar_thumbnail_url: avatar_thumbnail_url,
        banner_thumbnail_url: banner_thumbnail_url,
        grade_min: grade_min,
        grade_max: grade_max,
        last_activity_at: last_activity_at
      },
      geometry: { type: 'Point', "coordinates": [Float(partner_longitude), Float(partner_latitude), 0.0] }
    }
  end

  def avatar_thumbnail_url
    return unless avatar.attached?

    Rails.application.routes.url_helpers.rails_representation_url(avatar.variant(resize: '300x300').processed, only_path: true)
  end

  def banner_thumbnail_url
    return unless banner.attached?

    Rails.application.routes.url_helpers.rails_representation_url(banner.variant(resize: '300x300').processed, only_path: true)
  end

  private

  def set_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def init_last_activity_at
    self.last_activity_at ||= DateTime.current
  end

  def init_partner_search_activated_at
    return unless partner_search_changed?

    self.partner_search_activated_at = partner_search == true ? DateTime.current : nil
  end
end
