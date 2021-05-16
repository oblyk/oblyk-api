# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :reportable, polymorphic: true

  REPORTABLE_LIST = %w[
    Approach
    Area
    Crag
    CragSector
    CragRoute
    GuideBookPaper
    GuideBookPdf
    GuideBookWeb
    Comment
    Link
    Gym
    Photo
    Park
    PlacesOfSales
    Video
    Word
    User
    Organization
  ].freeze

  validates :reportable_type, inclusion: { in: REPORTABLE_LIST }
end
