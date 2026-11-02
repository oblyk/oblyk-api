# frozen_string_literal: true

class SprayWallRouteHoldSerializer < BaseSerializer
  belongs_to :spray_wall_route
  belongs_to :spray_wall_hold

  attributes :id,
             :hold_type,
             :hold_rule,
             :number
end
