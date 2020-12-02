# frozen_string_literal: true

class AreaCrag < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :crag
  belongs_to :area
end
