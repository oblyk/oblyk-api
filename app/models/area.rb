# frozen_string_literal: true

class Area < ApplicationRecord
  include Slugable
  include Searchable
  include AttachmentResizable

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
    Rails.cache.fetch("#{cache_key_with_version}/summary_area", expires_in: 28.days) do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        photo: {
          id: photo&.id,
          illustrable_type: photo&.illustrable_type,
          illustrable_name: photo&.illustrable&.rich_name,
          attachments: {
            picture: attachment_object(photo&.picture, 'Area_picture')
          }
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
    [{ value: name, column_names: %i[name] }]
  end
end
