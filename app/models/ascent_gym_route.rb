# frozen_string_literal: true

class AscentGymRoute < Ascent
  belongs_to :gym_route
  has_one :gym, through: :gym_route

  validates :ascent_status, inclusion: { in: AscentStatus::LIST }, allow_blank: true
  validates :climbing_type, inclusion: { in: Climb::GYM_LIST }
end
