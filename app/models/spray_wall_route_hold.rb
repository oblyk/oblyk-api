# frozen_string_literal: true

class SprayWallRouteHold < ApplicationRecord
  belongs_to :spray_wall_route
  belongs_to :spray_wall_hold

  before_validation :set_default

  validates :hold_type, presence: true, inclusion: { in: %w[start middle foot top] }
  validates :spray_wall_hold_id, uniqueness: { scope: :spray_wall_route_id }

  private

  def set_default
    self.hold_type ||= "middle"
  end
end
