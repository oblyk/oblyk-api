# frozen_string_literal: true

class TickList < ApplicationRecord
  belongs_to :user
  belongs_to :crag_route
end
