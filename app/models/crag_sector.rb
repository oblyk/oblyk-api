# frozen_string_literal: true

class CragSector < ApplicationRecord
  include Geolocable
  include SoftDeletable
  include Searchable
  include Slugable

  has_paper_trail only: %i[
    name
    description
    rain
    sun
    latitude
    longitude
    north
    north_east
    east
    south_east
    south
    south_west
    west
    north_west
  ]

  has_one_attached :picture
  belongs_to :user, optional: true
  belongs_to :photo, optional: true
  belongs_to :crag
  has_many :comments, as: :commentable
  has_many :links, as: :linkable
  has_many :alerts, as: :alertable
  has_many :photos, as: :illustrable
  has_many :crag_routes
  has_many :reports, as: :reportable

  validates :name, presence: true
  validates :rain, inclusion: { in: Rain::LIST }, allow_nil: true
  validates :sun, inclusion: { in: Sun::LIST }, allow_nil: true

  def search_json
    JSON.parse(
      ApplicationController.render(
        template: 'api/v1/crag_sectors/search.json',
        assigns: { crag_sector: self }
      )
    )
  end

  def all_photos
    photos = self.photos
    crag_routes.each { |crag_route| photos += crag_route.photos }
    photos
  end

  def all_videos
    videos = []
    crag_routes.each { |crag_route| videos += crag_route.videos }
    videos
  end
end
