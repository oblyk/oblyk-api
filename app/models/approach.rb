# frozen_string_literal: true

class Approach < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :crag

  STYLES_LIST = %w[steep_descent soft_descent flat soft_ascent steep_ascent various].freeze

  validates :polyline, :length, presence: true
  validates :approach_type, inclusion: { in: STYLES_LIST }, allow_nil: true
end
