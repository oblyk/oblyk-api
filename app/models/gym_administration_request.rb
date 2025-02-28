# frozen_string_literal: true

class GymAdministrationRequest < ApplicationRecord
  include StripTagable
  include Emailable

  belongs_to :user
  belongs_to :gym

  validates :first_name, :last_name, :email, :justification, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  after_create :send_email_notification

  def accept!
    gym_administrator = GymAdministrator.new(
      user: user,
      gym: gym,
      roles: GymRole::LIST,
      requested_email: user.email
    )
    gym_administrator.save
  end

  def deal
    gym.administered?
  end

  def summary_to_json
    {
      id: id,
      gym_id: gym_id,
      user_id: user_id,
      justification: justification,
      email: email,
      first_name: first_name,
      last_name: last_name,
      gym: gym.summary_to_json,
      user: user&.summary_to_json,
      deal: deal,
      history: {
        created_at: created_at,
        updated_at: updated_at
      }
    }
  end

  private

  def send_email_notification
    GymMailer.with(
      user: user,
      gym: gym,
      email: email,
      first_name: first_name,
      last_name: last_name,
      justification: justification
    ).new_request.deliver_later

    GymMailer.with(
      gym: gym,
      email: email,
      first_name: first_name
    ).new_request_confirmation.deliver_later
  end
end
