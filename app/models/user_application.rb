# frozen_string_literal: true

class UserApplication < ApplicationRecord
  belongs_to :user

  validates :user_application_id, presence: true
  validates :user_id, uniqueness: { scope: :type }
  validates :type, inclusion: { in: %w[UserApplicationMyCompet] }

  before_validation :set_user_application_id

  def summary_to_json
    data = {
      id: id,
      type: type,
      status: status
    }
    data[:ffme_licence_number] = ffme_licence_number if type == 'UserApplicationMyCompet'
    data
  end

  def detail_to_json
    summary_to_json
  end

  private

  def set_user_application_id
    self.user_application_id ||= SecureRandom.uuid
  end
end
