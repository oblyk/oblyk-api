# frozen_string_literal: true

class Area < ApplicationRecord
  include Slugable
  include Searchable

  belongs_to :user, optional: true
  belongs_to :photo, optional: true
  has_many :area_crags, dependent: :destroy
  has_many :crags, through: :area_crags
  has_many :crag_routes, through: :crags
  has_many :reports, as: :reportable
  has_many :links, as: :linkable

  validates :name, presence: true

  def crag_routes_count
    crags.sum(:crag_routes_count)
  end

  def hardest_route
    crags.order(max_grade_value: :desc).first
  end

  def easiest_route
    crags.where.not(min_grade_value: nil).order(min_grade_value: :asc).first
  end

  def all_photos
    photos = []
    crags.each do |crag|
      crag.crag_sectors.each { |crag_sector| photos += crag_sector.photos }
      crag.crag_routes.each { |crag_route| photos += crag_route.photos }
      photos += crag.photos
    end
    photos
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_area", expires_in: 1.month) do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        photo: {
          id: photo&.id,
          url: photo ? photo.large_url : nil,
          cropped_url: photo ? photo.cropped_medium_url : nil,
          thumbnail_url: photo ? photo.thumbnail_url : nil,
          illustrable_type: photo ? photo.illustrable_type : nil,
          illustrable_name: photo ? photo.illustrable.rich_name : nil
        }
      }
    end
  end

  def detail_to_json
    summary_to_json.merge(
      {
        crags_count: crags.count,
        crag_routes_count: crag_routes_count,
        area_crags: area_crags.includes(:crag).map { |area_crag| { id: area_crag.id, crags: { id: area_crag.crag.id, name: area_crag.crag.name } } },
        routes_figures: {
          routes_count: crag_routes_count,
          grade: {
            min_value: easiest_route&.min_grade_value,
            min_text: easiest_route&.min_grade_text,
            max_value: hardest_route&.max_grade_value,
            max_text: hardest_route&.max_grade_text
          }
        },
        creator: user&.summary_to_json(with_avatar: false),
        history: {
          created_at: created_at,
          updated_at: updated_at
        }
      }
    )
  end

  private

  def search_indexes
    [{ value: name }]
  end
end
