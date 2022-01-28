# frozen_string_literal: true

class User < ApplicationRecord
  include Searchable
  include Geolocable
  include Slugable
  include ParentFeedable
  include AttachmentResizable
  include StripTagable

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
  has_many :administered_gyms, through: :gym_administrators, source: :gym
  has_many :gyms
  has_many :reports, as: :reportable
  has_many :ascent_crag_routes
  has_many :ascended_crag_routes, through: :ascent_crag_routes, source: :crag_route
  has_many :ascended_crags, through: :ascended_crag_routes, source: :crag
  has_many :ascent_gym_routes
  has_many :ascent_users
  has_many :organization_users
  has_many :organizations, through: :organization_users
  has_many :notifications
  has_many :alerts
  has_many :approaches
  has_many :area_crags
  has_many :areas
  has_many :article_crags
  has_many :article_guide_book_papers
  has_many :authors
  has_many :comments
  has_many :crag_routes
  has_many :crag_sectors
  has_many :crags
  has_many :guide_book_papers
  has_many :guide_book_pdfs
  has_many :guide_book_webs
  has_many :links
  has_many :parks
  has_many :place_of_sales
  has_many :refresh_tokens
  has_many :reports
  has_many :words

  before_validation :set_uuid
  before_validation :set_ws_token
  before_validation :init_last_activity_at
  before_create :init_email_notifiable_list
  before_validation :init_partner_search_activated_at

  validates :first_name, :email, :uuid, :ws_token, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: proc { |obj| obj.deleted_at.blank? }
  validates :email, uniqueness: true
  validates :uuid, uniqueness: true, on: :create
  validates :ws_token, uniqueness: true, on: :create
  validates :genre, inclusion: { in: %w[male female] }, allow_blank: true
  validates :language, inclusion: { in: %w[fr en] }, allow_blank: true

  validates :partner_latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_blank: true
  validates :partner_longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_blank: true

  validates :avatar, blob: { content_type: :image }, allow_nil: true
  validates :banner, blob: { content_type: :image }, allow_nil: true
  validate :validate_email_notifiable_list

  scope :partner_geolocable, -> { where(partner_search: true).where.not(partner_latitude: nil).where.not(partner_longitude: nil) }
  scope :deleted, -> { where(deleted_at: nil) }
  scope :undeleted, -> { where.not(deleted_at: nil) }

  def location
    [latitude, longitude]
  end

  def partner_location
    [partner_latitude, partner_longitude]
  end

  def full_name
    "#{first_name} #{last_name}".strip
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

  def ascent_gym_routes_to_a
    json_ascents = []
    ascent_gym_routes.where.not(gym_route_id: nil).each do |ascent|
      json_ascents << {
        gym_route_id: ascent.gym_route_id,
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
    update_column(:last_activity_at, DateTime.current)
  end

  def age
    date_of_birth.present? ? ((Time.zone.now - Time.zone.parse(date_of_birth.to_s)) / 1.year.seconds).floor : nil
  end

  def to_partner_geo_json
    Rails.cache.fetch("#{cache_key_with_version}/partner_geo_json", expires_in: 1.day) do
      {
        type: 'Feature',
        properties: {
          type: 'PartnerUser',
          uuid: uuid,
          full_name: full_name,
          slug_name: slug_name,
          description: description ? Markdown.new(description, :hard_wrap).to_html.html_safe : '',
          age: age,
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
  end

  def avatar_large_url
    resize_attachment avatar, '500x500'
  end

  def avatar_thumbnail_url
    resize_attachment avatar, '300x300'
  end

  def banner_large_url
    resize_attachment banner, '1920x1920'
  end

  def banner_thumbnail_url
    resize_attachment banner, '300x300'
  end

  def subscribe_to_newsletter?
    subscribe = Subscribe.find_by(email: email)
    subscribe.present?
  end

  def deletable?
    deleted_at.blank?
  end

  def destroy
    delete
  end

  def delete
    return unless deletable?

    ActiveRecord::Base.transaction do
      self.first_name = 'Anonyme'
      self.last_name = nil
      self.email = "#{Date.current}-#{id}@delete.mail"
      self.password_digest = "deleted-user-#{id}"
      self.date_of_birth = Date.current
      self.genre = nil
      self.description = nil
      self.partner_search = 0
      self.latitude = nil
      self.longitude = nil
      self.bouldering = 0
      self.sport_climbing = 0
      self.multi_pitch = 0
      self.trad_climbing = 0
      self.aid_climbing = 0
      self.deep_water = 0
      self.via_ferrata = 0
      self.pan = 0
      self.grade_max = nil
      self.grade_min = nil
      self.slug_name = 'anonymous'
      self.localization = nil
      self.language = nil
      self.reset_password_token = nil
      self.reset_password_token_expired_at = nil
      self.public_profile = 0
      self.public_outdoor_ascents = 0
      self.public_indoor_ascents = 0
      self.partner_latitude = nil
      self.partner_longitude = nil
      self.last_activity_at = nil
      self.partner_search_activated_at = nil
      self.email_notifiable_list = nil
      self.deleted_at = Time.current

      if save
        # Purge avatar & banner
        avatar.purge
        banner.purge

        # Destroy relation
        follows.destroy_all
        subscribes.destroy_all
        tick_lists.destroy_all
        ascent_crag_routes.destroy_all
        ascent_gym_routes.destroy_all
        gym_administrators.destroy_all
        ascent_users.destroy_all
        organization_users.destroy_all
        notifications.destroy_all
        refresh_tokens.destroy_all

        # Purge feed in relation
        Feed.where(parent_id: id, parent_type: 'User').destroy_all
        Feed.where(feedable_id: id, feedable_type: 'User').destroy_all
      end
    end
  end

  def summary_to_json
    {
      id: id,
      uuid: uuid,
      slug_name: slug_name,
      first_name: first_name,
      full_name: full_name,
      avatar_thumbnail_url: avatar_thumbnail_url
    }
  end

  def detail_to_json(current_user: false)
    user_data = {
      id: id,
      uuid: uuid,
      first_name: first_name,
      last_name: last_name,
      slug_name: slug_name,
      genre: genre,
      description: description,
      localization: localization,
      partner_search: partner_search,
      partner_latitude: partner_latitude,
      partner_longitude: partner_longitude,
      bouldering: bouldering,
      sport_climbing: sport_climbing,
      multi_pitch: multi_pitch,
      trad_climbing: trad_climbing,
      aid_climbing: aid_climbing,
      deep_water: deep_water,
      via_ferrata: via_ferrata,
      pan: pan,
      grade_max: grade_max,
      grade_min: grade_min,
      public_profile: public_profile,
      public_outdoor_ascents: public_outdoor_ascents,
      public_indoor_ascents: public_indoor_ascents,
      last_activity_at: last_activity_at,
      age: age,
      followers_count: follows.count || 0,
      subscribes_count: subscribes.count,
      videos_count: videos.count,
      photos_count: photos.count,
      full_name: full_name,
      banner: banner.attached? ? banner_large_url : nil,
      avatar: avatar.attached? ? avatar_large_url : nil
    }
    if current_user
      user_data = user_data.merge(
        {
          super_admin: super_admin,
          email_notifiable_list: email_notifiable_list,
          email: email,
          ws_token: ws_token,
          date_of_birth: date_of_birth,
          language: language,
          administered_gyms: administered_gyms.map(&:summary_to_json),
          organizations: organizations.map(&:summary_to_json),
          subscribes: subscribes_to_a,
          ascent_crag_routes: ascent_crag_routes_to_a,
          ascent_gym_routes: ascent_gym_routes_to_a,
          tick_list: tick_list_to_a
        }
      )
    end
    user_data
  end

  private

  def search_indexes
    [{ value: full_name }]
  end

  def set_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def set_ws_token
    self.ws_token ||= SecureRandom.urlsafe_base64(32)
  end

  def init_last_activity_at
    self.last_activity_at ||= DateTime.current
  end

  def init_email_notifiable_list
    self.email_notifiable_list ||= ['new_message']
  end

  def init_partner_search_activated_at
    return unless partner_search_changed?

    self.partner_search_activated_at = partner_search == true ? DateTime.current : nil
  end

  def validate_email_notifiable_list
    return if email_notifiable_list.blank? || email_notifiable_list&.count&.zero?

    email_notifiable_list.each do |email_notifiable|
      errors.add(:email_notifiable, I18n.t('activerecord.errors.messages.inclusion')) if Notification::EMAILABLE_NOTIFICATION_LIST.exclude? email_notifiable
    end
  end
end
