# frozen_string_literal: true

class Department < ApplicationRecord
  include RouteFigurable
  include AttachmentResizable

  belongs_to :country
  has_many :towns
  has_many :crags
  has_many :gyms
  has_many :crag_routes, through: :crags

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_department", expires_in: 28.days) do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        department_number: department_number,
        name_prefix_type: name_prefix_type,
        in_sentence_prefix_type: in_sentence_prefix_type,
        country: country.summary_to_json
      }
    end
  end

  def detail_to_json
    guide_ids = []
    crags.includes(:guide_book_papers).find_each do |crag|
      crag.guide_book_papers.each do |guide|
        next if guide.next_guide_book_paper_id.present?
        next if guide_ids.include? guide.id

        guide_ids << guide.id
      end
    end

    hardest_sport_climbing = crag_routes.where(climbing_type: 'sport_climbing').order(max_grade_value: :desc).first
    hardest_bouldering = crag_routes.where(climbing_type: 'bouldering').order(max_grade_value: :desc).first

    guide_books = GuideBookPaper.select(%i[id slug_name name author])
                                .includes(cover_attachment: :blob)
                                .where(id: guide_ids)
                                .order(publication_year: :desc)
    guide_book_papers = guide_books.map do |guide_book|
      {
        id: guide_book.id,
        slug_name: guide_book.slug_name,
        name: guide_book.name,
        author: guide_book.author,
        attachments: {
          cover: attachment_object(guide_book.cover)
        }
      }
    end

    summary_to_json.merge(
      {
        towns: towns.order(:name).map { |town| { name: town.name, slug_name: town.slug_name, zipcode: town.zipcode } },
        guide_book_papers: guide_book_papers,
        figures: {
          crags: {
            count: {
              all: crags.count,
              types: {
                sport_climbing: crags.where(sport_climbing: true).count,
                bouldering: crags.where(bouldering: true).count,
                multi_pitch: crags.where(multi_pitch: true).count,
                trad_climbing: crags.where(trad_climbing: true).count,
                aid_climbing: crags.where(aid_climbing: true).count,
                deep_water: crags.where(deep_water: true).count,
                via_ferrata: crags.where(via_ferrata: true).count
              }
            }
          },
          crag_routes: {
            count: {
              all: crag_routes.count
            },
            hardest_sport_climbing: hardest_sport_climbing&.summary_to_json,
            hardest_bouldering: hardest_bouldering&.summary_to_json
          },
          gyms: {
            count: {
              all: gyms.count
            }
          }
        }
      }
    )
  end

  def to_geo_json
    {
      type: 'Feature',
      properties: {
        type: 'Department',
        id: id,
        name: name,
        slug_name: slug_name,
        department_number: department_number,
        country_code: country.code_country,
        country_slug_name: country.slug_name
      },
      geometry: { type: 'Polygon', "coordinates": geo_polygon }
    }
  end
end
