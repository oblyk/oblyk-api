# frozen_string_literal: true

class GymAdministrator < ApplicationRecord
  include Emailable

  belongs_to :user, optional: true
  belongs_to :gym

  validates :requested_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :validate_roles

  after_create :set_gym_is_administered

  def summary_to_json
    data = {
      id: id,
      user_id: user_id,
      gym_id: gym_id,
      roles: roles,
      requested_email: requested_email,
      subscribe_to_comment_feed: subscribe_to_comment_feed,
      subscribe_to_video_feed: subscribe_to_video_feed,
      subscribe_to_follower_feed: subscribe_to_follower_feed,
      last_comment_feed_read_at: last_comment_feed_read_at,
      last_video_feed_read_at: last_video_feed_read_at,
      last_follower_feed_read_at: last_follower_feed_read_at
    }
    if user
      data[:user] = {
        id: user.id,
        slug_name: user.slug_name,
        full_name: user.full_name
      }
    end
    data
  end

  def detail_to_json
    data = summary_to_json
    data[:gym] = gym.summary_to_json
    data[:user] = user.summary_to_json if user
    data
  end

  def send_invitation_email!(host)
    GymMailer.with(user: user, gym: gym, host: host, requested_email: requested_email)
             .new_administrator
             .deliver_later
  end

  private

  def set_gym_is_administered
    gym.administered! unless gym.administered?
  end

  def validate_roles
    return unless roles

    (roles || []).each do |role|
      errors.add(:roles, I18n.t('activerecord.errors.messages.inclusion')) unless GymRole::LIST.include? role
    end
  end
end
