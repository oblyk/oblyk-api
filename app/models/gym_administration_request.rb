# frozen_string_literal: true

class GymAdministrationRequest < ApplicationRecord
  belongs_to :user
  belongs_to :gym

  validates :first_name, :last_name, :email, :justification, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
