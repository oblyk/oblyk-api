# frozen_string_literal: true

class CragSerializer
  include JSONAPI::Serializer
  include AttachmentsSerializerHelper

  attributes :id,
             :name,
             :app_path,
             :slug_name,
             :latitude,
             :longitude,
             :rain,
             :sun,
             :sport_climbing,
             :bouldering,
             :multi_pitch,
             :trad_climbing,
             :aid_climbing,
             :deep_water,
             :via_ferrata,
             :north,
             :north_east,
             :east,
             :south_east,
             :south,
             :south_west,
             :west,
             :north_west,
             :summer,
             :autumn,
             :winter,
             :spring,
             :elevation,
             :code_country,
             :country,
             :city,
             :region,
             :rocks,
             :crag_routes_count,
             :follows_count,
             :ascents_count,
             :ascent_users_count

  attribute :approaches do |object|
    {
      min_time: object.min_approach_time,
      max_time: object.max_approach_time
    }
  end

  attribute :routes_figures do |object|
    {
      route_count: object.crag_routes_count,
      grade: {
        min_value: object.min_grade_value,
        max_value: object.max_grade_value,
        max_text: object.max_grade_text,
        min_text: object.min_grade_text
      }
    }
  end

  def self.cover_attachment(object)
    object.photo_id.present? ? object.attachment_object(object.photo.picture, 'Crag_cover') : object.attachment_object(object.static_map, 'Crag_cover')
  end

  def self.avatar_attachment(object)
    cover_attachment(object)
  end

  def self.static_map_attachment(object)
    object.attachment_object(object.static_map)
  end

  def self.static_map_banner_attachment(object)
    object.attachment_object(object.static_map_banner)
  end
end
