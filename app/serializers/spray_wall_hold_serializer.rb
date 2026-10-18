# frozen_string_literal: true

class SprayWallHoldSerializer < BaseSerializer
  belongs_to :spray_wall

  attributes :id,
             :points,
             :cx,
             :cy,
             :area,
             :min_x,
             :min_y,
             :max_x,
             :max_y,
             :active,
             :source,
             :confidence
end
