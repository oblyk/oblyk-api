# frozen_string_literal: true

class GymAdministrationRequest < ApplicationRecord
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
  end
end
