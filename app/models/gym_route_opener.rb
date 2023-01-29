# frozen_string_literal: true

class GymRouteOpener < ApplicationRecord
  belongs_to :gym_opener
  belongs_to :gym_route
end
