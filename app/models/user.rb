# frozen_string_literal: true

class User < ApplicationRecord
  include Geolocable
  include Slugable

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
  has_many :gym_administrators
  has_many :gyms, through: :gym_administrators
  has_many :reports, as: :reportable
  has_many :ascent_crag_routes
  has_many :ascended_crag_routes, through: :ascent_crag_routes, source: :crag_route
  has_many :ascended_crags, through: :ascended_crag_routes, source: :crag
  has_many :ascent_gym_routes

  before_validation :set_uuid

  validates :first_name, :email, :uuid, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: true, on: :create
  validates :uuid, uniqueness: true, on: :create
  validates :genre, inclusion: { in: %w[male female] }, allow_blank: true
  validates :language, inclusion: { in: %w[fr en] }

  validates :avatar, blob: { content_type: :image }, allow_nil: true
  validates :banner, blob: { content_type: :image }, allow_nil: true

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

  def tick_list_to_a
    tick_lists.pluck(:crag_route_id)
  end

  private

  def set_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
