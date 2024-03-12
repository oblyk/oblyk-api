# frozen_string_literal: true

class User < ApplicationRecord
  include Searchable
  include ParentFeedable
  include AttachmentResizable
  include StripTagable
  include Emailable

  PASSWORD_FORMAT = /\A
      (?=.{8,128}) # Must contain 8 or more characters
      (?=.*\d)     # Must contain a digit
      (?=.*[a-z])  # Must contain a lower case character
      (?=.*[A-Z])  # Must contain an upper case character
    /x.freeze

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
  has_many :gym_chain_administrators
  has_many :gym_chains, through: :gym_chain_administrators
  has_many :gyms
  has_many :reports, as: :reportable
  has_many :ascent_crag_routes
  has_many :ascended_crag_routes, through: :ascent_crag_routes, source: :crag_route
  has_many :ascended_crags, through: :ascended_crag_routes, source: :crag
  has_many :ascent_gym_routes
  has_many :ascended_gyms, through: :ascent_gym_routes, source: :gym
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
  has_many :rock_bars
  has_many :guide_book_papers
  has_many :guide_book_pdfs
  has_many :guide_book_webs
  has_many :links
  has_many :parks
  has_many :place_of_sales
  has_many :refresh_tokens
  has_many :reports
  has_many :words
  has_many :climbing_sessions
  has_many :gym_openers
  has_many :locality_users
  has_many :localities, through: :locality_users
  has_many :likes
  has_many :contest_participants

  before_validation :init_slug_name
  before_validation :set_uuid
  before_validation :set_ws_token
  before_validation :init_last_activity_at
  before_validation :uncheck_partner_if_minor
  before_create :init_email_notifiable_list
  before_validation :init_partner_search_activated_at
  after_create :link_gym_administrators
  after_update :update_user_localities

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

  validates :password, presence: true, format: { with: PASSWORD_FORMAT }, confirmation: true, on: :create
  validates :password, allow_nil: true, format: { with: PASSWORD_FORMAT }, confirmation: true, on: :update

  validate :validate_email_notifiable_list

  validate :can_change_date_of_birth

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
        roping_status: ascent.roping_status,
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

  def partner_check!
    update_columns(
      last_partner_check_at: DateTime.current,
      partner_notified_at: nil
    )
  end

  def age
    date_of_birth.present? ? ((Time.zone.now - Time.zone.parse(date_of_birth.to_s)) / 1.year.seconds).floor : nil
  end

  def user_subscribes
    subscribes.accepted.where(followable_type: 'User')
  end

  def to_partner_geo_json(minimalistic: false)
    Rails.cache.fetch("#{cache_key_with_version}/#{'minimalistic_' if minimalistic}partner_geo_json", expires_in: 28.days) do
      features = {
        type: 'Feature',
        properties: {
          type: 'PartnerUser',
          uuid: uuid,
          icon: 'partner-user',
          avatar_thumbnail_url: avatar_thumbnail_url
        },
        geometry: { type: 'Point', "coordinates": [Float(partner_longitude), Float(partner_latitude), 0.0] }
      }
      unless minimalistic
        features[:properties].merge!(
          {
            full_name: full_name,
            slug_name: slug_name,
            description: description ? Markdown.new(description, :hard_wrap).to_html.html_safe : '',
            age: age,
            genre: genre,
            sport_climbing: sport_climbing,
            bouldering: bouldering,
            multi_pitch: multi_pitch,
            trad_climbing: trad_climbing,
            aid_climbing: aid_climbing,
            deep_water: deep_water,
            via_ferrata: via_ferrata,
            pan: pan,
            banner_thumbnail_url: banner_thumbnail_url,
            grade_min: grade_min,
            grade_max: grade_max,
            last_activity_at: last_activity_at
          }
        )
      end
      features
    end
  end

  def local_climber_to_json
    Rails.cache.fetch("#{cache_key_with_version}/local_climber_to_json", expires_in: 28.days) do
      {
        uuid: uuid,
        avatar_thumbnail_url: avatar_thumbnail_url,
        first_name: first_name,
        full_name: full_name,
        slug_name: slug_name,
        description: description ? Markdown.new(description, :hard_wrap).to_html.html_safe : '',
        age: age,
        genre: genre,
        partner_search: partner_search,
        sport_climbing: sport_climbing,
        bouldering: bouldering,
        multi_pitch: multi_pitch,
        trad_climbing: trad_climbing,
        aid_climbing: aid_climbing,
        deep_water: deep_water,
        via_ferrata: via_ferrata,
        pan: pan,
        banner_thumbnail_url: banner_thumbnail_url,
        grade_min: grade_min,
        grade_max: grade_max,
        last_activity_at: last_activity_at
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

  def banner_cropped_medium_url
    crop_attachment banner, '500x500'
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
        climbing_sessions.destroy_all
        locality_users.destroy_all
        gym_openers.update_all(user_id: nil)
        likes.destroy_all

        # Purge feed in relation
        Feed.where(parent_id: id, parent_type: 'User').destroy_all
        Feed.where(feedable_id: id, feedable_type: 'User').destroy_all
      end
    end
  end

  def summary_to_json(with_avatar: true)
    Rails.cache.fetch("#{cache_key_with_version}/summary_user#{'_with_avatar' if with_avatar}", expires_in: 28.days) do
      json = {
        id: id,
        uuid: uuid,
        slug_name: slug_name,
        first_name: first_name,
        full_name: full_name
      }
      json[:avatar_thumbnail_url] = avatar_thumbnail_url if with_avatar
      json
    end
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
      partner_search: partner_search,
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
      user_subscribes_count: user_subscribes.count,
      videos_count: videos.count,
      photos_count: photos.count,
      full_name: full_name,
      banner_thumbnail_url: banner.attached? ? banner_thumbnail_url : nil,
      banner_cropped_url: banner.attached? ? banner_cropped_medium_url : nil,
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
          last_partner_check_at: last_partner_check_at,
          language: language,
          administered_gyms: administered_gyms.order(:name).map(&:summary_to_json),
          gym_chains: gym_chains.map(&:summary_to_json),
          gym_roles: gym_administrators.map(&:summary_to_json),
          organizations: organizations.map(&:summary_to_json),
          subscribes: subscribes_to_a,
          ascent_crag_routes: ascent_crag_routes_to_a,
          ascent_gym_routes: ascent_gym_routes_to_a,
          tick_list: tick_list_to_a,
          minor: minor?
        }
      )
    end
    user_data
  end

  def find_slug_name(potential_slug)
    # return potential slug if is free
    return potential_slug if User.where.not(id: id).where(slug_name: potential_slug).blank?

    # find user with slug_name an -[digit] at the end
    same_slug_users = User.where.not(id: id).where("slug_name RLIKE '^#{potential_slug}-[0-9]$'")

    if same_slug_users.blank?
      # Return potential_slug with -1 if is the first duplicate slug
      "#{potential_slug}-1"
    else
      slug_indexes = []
      same_slug_users.find_each do |user|
        slug_indexes << user.slug_name.split('-').last.to_i
      end
      slug_indexes.sort!
      slug_indexes.each_with_index do |slug_index, index|
        # Use missing digit if existe like : slug-1, slug-3, slug-4 => use slug-2
        return "#{potential_slug}-#{index + 1}" if slug_index != index + 1
      end

      # Use last slug digit + 1
      "#{potential_slug}-#{slug_indexes.last + 1}"
    end
  end

  def minor?
    date_of_birth.present? && date_of_birth > Date.current - 18.years
  end

  def delete_summary_cache
    Rails.cache.delete("#{cache_key_with_version}/summary_user")
    Rails.cache.delete("#{cache_key_with_version}/summary_user_with_avatar")
    Rails.cache.delete("#{cache_key_with_version}/local_climber_to_json")
    Rails.cache.delete("#{cache_key_with_version}/partner_geo_json")
    Rails.cache.delete("#{cache_key_with_version}/minimalistic_partner_geo_json")
  end

  private

  def search_indexes
    [{ value: full_name, column_names: %i[first_name last_name] }]
  end

  def init_slug_name
    return if slug_name.present?

    slug_proposition = "#{first_name} #{last_name}".parameterize
    self.slug_name = find_slug_name slug_proposition
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

  def update_user_localities
    # return unless partner_search_changed?

    localities.each(&:update_climber_counts!)
  end

  def link_gym_administrators
    GymAdministrator.where(requested_email: email).where(user: nil).find_each do |gym_administrator|
      gym_administrator.user = self
      gym_administrator.save
    end
  end

  def uncheck_partner_if_minor
    return unless date_of_birth

    self.partner_search = nil if date_of_birth >= Date.current - 18.years
  end

  def can_change_date_of_birth
    return if new_record?
    return unless date_of_birth_was
    return unless date_of_birth_changed?

    errors.add(:date_of_birth, 'cannot_be_changed') if date_of_birth_was >= Date.current - 18.years
  end
end
