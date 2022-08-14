# frozen_string_literal: true

class Town < ApplicationRecord
  include Geolocable
  include RouteFigurable

  belongs_to :department
  has_one :country, through: :department

  attr_accessor :dist_around

  def default_dist
    if population <= 10_000
      10
    elsif population <= 25_000
      15
    elsif population <= 50_000
      20
    else
      30
    end
  end

  def crags
    Crag.includes(:crag_routes).geo_search(latitude, longitude, dist_around)
  end

  def crag_routes
    CragRoute.where(crag_id: crags.pluck(:id))
  end

  def gyms
    Gym.geo_search(latitude, longitude, dist_around)
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_town", expires_in: 1.month) do
      {
        id: id,
        name: name,
        slug_name: slug_name,
        latitude: latitude,
        longitude: longitude,
        town_code: town_code,
        zipcode: zipcode,
        department: department.summary_to_json
      }
    end
  end

  def detail_to_json(dist)
    self.dist_around = dist
    nearest_crag = Crag.order("getRange(crags.latitude, crags.longitude, #{latitude.to_f} , #{longitude.to_f})").first
    nearest_gym = Gym.order("getRange(gyms.latitude, gyms.longitude, #{latitude.to_f} , #{longitude.to_f})").first

    nearest_crag_dist = GeoHelper.geo_range(latitude, longitude, nearest_crag.latitude, nearest_crag.longitude)
    nearest_gym_dist = GeoHelper.geo_range(latitude, longitude, nearest_gym.latitude, nearest_gym.longitude)

    around_crags = crags.includes(photo: { picture_attachment: :blob })
    around_gyms = gyms.includes(logo_attachment: :blob, banner_attachment: :blob)

    guide_book_papers = GuideBookPaper.includes(:guide_book_paper_crags, cover_attachment: :blob )
                                      .where(guide_book_paper_crags: { crag_id: around_crags.select(:id) })

    crag_with_levels = {}
    around_crags.each do |crag|
      crag_with_levels["crag-#{crag.id}"] ||= {
        levels: {},
        crag: crag
      }

      crag.crag_routes.each do |crag_route|
        next if crag_route.max_grade_value.zero?

        crag_with_levels["crag-#{crag.id}"][:levels][crag_route.max_grade_value] ||= { count: 0}
        crag_with_levels["crag-#{crag.id}"][:levels][crag_route.max_grade_value][:count] += 1
      end
    end

    summary_to_json.merge(
      {
        dist: dist,
        crags: {
          nearest: nearest_crag.summary_to_json,
          nearest_dist: nearest_crag_dist,
          around: around_crags.map(&:summary_to_json),
          route_figures: route_figures,
          crag_with_levels: crag_with_levels
        },
        gyms: {
          nearest: nearest_gym.summary_to_json,
          nearest_dist: nearest_gym_dist,
          around: around_gyms.map(&:summary_to_json)
        },
        guide_book_papers: guide_book_papers.map(&:summary_to_json)
      }
    )
  end
end
