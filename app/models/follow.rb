# frozen_string_literal: true

class Follow < ApplicationRecord
  belongs_to :followable, polymorphic: true
  belongs_to :user

  before_validation :auto_accepted

  validates :followable_type, inclusion: { in: %w[User Crag CragSector CragRoute Gym].freeze }

  private

  def auto_accepted
    self.accepted_at = Time.current if %w[Crag CragSector CragRoute].include? followable_type
    return unless followable_type == 'User'

    target_user = User.find followable_id
    self.accepted_at = Time.current if target_user.public?
  end
end
