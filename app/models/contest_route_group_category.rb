# frozen_string_literal: true

class ContestRouteGroupCategory < ApplicationRecord
  belongs_to :contest_category
  belongs_to :contest_route_group
end
