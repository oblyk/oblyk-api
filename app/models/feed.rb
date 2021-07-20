# frozen_string_literal: true

class Feed < ApplicationRecord
  belongs_to :feedable, polymorphic: true

  FEEDABLE_LIST = %w[Crag CragRoute GuideBookPaper GuideBookWeb GuideBookPdf Gym Alert Word Photo Video AscentCragRoute User Article].freeze

  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_blank: true
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_blank: true
  validates :feedable_type, inclusion: { in: FEEDABLE_LIST }

  def location
    [latitude, longitude]
  end
end
