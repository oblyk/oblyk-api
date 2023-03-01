# frozen_string_literal: true

class GymAdministrator < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :gym

  validate :validate_roles

  after_create :set_gym_is_administered

  def summary_to_json
    data = {
      id: id,
      user_id: user_id,
      gym_id: gym_id,
      roles: roles,
      requested_email: requested_email
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
    gym.administered!
  end

  def validate_roles
    return unless roles

    (roles || []).each do |role|
      errors.add(:roles, I18n.t('activerecord.errors.messages.inclusion')) unless GymRole::LIST.include? role
    end
  end
end
