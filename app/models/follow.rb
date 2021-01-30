# frozen_string_literal: true

class Follow < ApplicationRecord
  belongs_to :followable, polymorphic: true
  belongs_to :user

  before_validation :auto_accepted

  FOLLOWABLE_LIST = %w[
    User
    Crag
    GuideBookPaper
    Gym
  ].freeze

  validates :followable_type, inclusion: { in: FOLLOWABLE_LIST }

  def accepted?
    accepted_at.present?
  end

  def increment!
    self.views = views + 1
    save!
  end

  private

  def auto_accepted
    self.accepted_at = Time.current if %w[Crag Gym].include? followable_type
    return unless followable_type == 'User'

    target_user = User.find followable_id
    self.accepted_at = Time.current if target_user.public?
  end
end
