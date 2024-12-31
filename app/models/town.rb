# frozen_string_literal: true

class Town < ApplicationRecord
  include Geolocable
  include RouteFigurable
  include AttachmentResizable

  belongs_to :department
  has_one :country, through: :department
  has_many :town_json_objects

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
    @crag_routes ||= CragRoute.where(crag_id: crags.pluck(:id).uniq)
  end

  def gyms
    Gym.geo_search(latitude, longitude, dist_around)
  end

  def summary_to_json
    Rails.cache.fetch("#{cache_key_with_version}/summary_town", expires_in: 28.days) do
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

    nearest_gym = nil
    nearest_gym_dist = nil

    around_gyms = gyms.select(%i[id slug_name name country city]).includes(logo_attachment: :blob).map do |gym|
      {
        id: gym.id,
        slug_name: gym.slug_name,
        name: gym.name,
        country: gym.country,
        city: gym.city,
        attachments: {
          logo: attachment_object(gym.logo)
        }
      }
    end

    if around_gyms.size.zero?
      first_nearest_gym = Gym.select(%i[id slug_name name country city latitude longitude])
                             .order("getRange(gyms.latitude, gyms.longitude, #{latitude.to_f} , #{longitude.to_f})")
                             .first
      nearest_gym = {
        id: first_nearest_gym.id,
        slug_name: first_nearest_gym.slug_name,
        name: first_nearest_gym.name,
        country: first_nearest_gym.country,
        city: first_nearest_gym.city,
        attachments: {
          logo: attachment_object(first_nearest_gym.logo)
        }
      }
      nearest_gym_dist = GeoHelper.geo_range(latitude, longitude, first_nearest_gym.latitude, first_nearest_gym.longitude)
    end

    guide_book_papers = []
    nearest_crag = nil
    nearest_crag_dist = nil

    around_crags = crags.select(
      :id, :name, :slug_name, :sport_climbing, :bouldering, :multi_pitch, :trad_climbing, :aid_climbing, :deep_water,
      :via_ferrata, :north, :north_east, :east, :south_east, :south, :south_west, :west, :north_west, :summer,
      :autumn, :winter, :spring, :min_approach_time, :max_approach_time
    ).includes(:crag_routes)

    crag_with_levels = {}
    climbing_types = {
      sport_climbing: 0,
      bouldering: 0,
      multi_pitch: 0,
      trad_climbing: 0,
      aid_climbing: 0,
      deep_water: 0,
      via_ferrata: 0
    }
    around_crags.each do |crag|
      climbing_types[:sport_climbing] += 1 if crag.sport_climbing
      climbing_types[:bouldering] += 1 if crag.bouldering
      climbing_types[:multi_pitch] += 1 if crag.multi_pitch
      climbing_types[:trad_climbing] += 1 if crag.trad_climbing
      climbing_types[:aid_climbing] += 1 if crag.aid_climbing
      climbing_types[:deep_water] += 1 if crag.deep_water
      climbing_types[:via_ferrata] += 1 if crag.via_ferrata

      crag_with_levels["crag-#{crag.id}"] ||= {
        levels: {},
        crag: crag_summary_to_json(crag)
      }

      crag.crag_routes.each do |crag_route|
        next if crag_route.max_grade_value.zero?

        crag_with_levels["crag-#{crag.id}"][:levels][crag_route.max_grade_value] ||= { count: 0 }
        crag_with_levels["crag-#{crag.id}"][:levels][crag_route.max_grade_value][:count] += 1
      end
    end

    if around_crags.size.zero?
      first_nearest_crag = Crag.order("getRange(crags.latitude, crags.longitude, #{latitude.to_f} , #{longitude.to_f})").first
      nearest_crag_dist = GeoHelper.geo_range(latitude, longitude, first_nearest_crag.latitude, first_nearest_crag.longitude)
      nearest_crag = {
        id: first_nearest_crag.id,
        name: first_nearest_crag.name,
        slug_name: first_nearest_crag.slug_name,
        country: first_nearest_crag.country,
        city: first_nearest_crag.city,
        photo: {
          attachments: {
            picture: attachment_object(first_nearest_crag.photo&.picture, 'Crag_picture')
          }
        }
      }
    else
      guide_book_papers = GuideBookPaper.select(%i[id slug_name name author])
                                        .includes(:guide_book_paper_crags, cover_attachment: :blob)
                                        .where(guide_book_paper_crags: { crag_id: around_crags.map(&:id) })
                                        .map do |guide_book|
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
    end

    summary_to_json.merge(
      {
        dist: dist,
        crags: {
          nearest: nearest_crag,
          nearest_dist: nearest_crag_dist,
          crag_count_around: around_crags.size,
          crag_count_by_climbing_types: climbing_types,
          route_figures: around_crags.size.positive? ? route_figures : nil,
          crag_with_levels: crag_with_levels
        },
        gyms: {
          nearest: nearest_gym,
          nearest_dist: nearest_gym_dist,
          around: around_gyms
        },
        guide_book_papers: guide_book_papers
      }
    )
  end

  def historize!
    touch
    reload
    historize_date = updated_at
    dist = default_dist
    town_json_object = TownJsonObject.find_or_initialize_by town: self, dist: dist
    town_json_object.json_object = detail_to_json dist
    town_json_object.version_date = historize_date
    town_json_object.save!
  end

  private

  def crag_summary_to_json(crag)
    {
      id: crag.id,
      name: crag.name,
      slug_name: crag.slug_name,
      sport_climbing: crag.sport_climbing,
      bouldering: crag.bouldering,
      multi_pitch: crag.multi_pitch,
      trad_climbing: crag.trad_climbing,
      aid_climbing: crag.aid_climbing,
      deep_water: crag.deep_water,
      via_ferrata: crag.via_ferrata,
      north: crag.north,
      north_east: crag.north_east,
      east: crag.east,
      south_east: crag.south_east,
      south: crag.south,
      south_west: crag.south_west,
      west: crag.west,
      north_west: crag.north_west,
      summer: crag.summer,
      autumn: crag.autumn,
      winter: crag.winter,
      spring: crag.spring,
      min_approach_time: crag.min_approach_time,
      max_approach_time: crag.max_approach_time
    }
  end
end
