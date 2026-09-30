# frozen_string_literal: true

class CragSerializer < BaseSerializer
  include AttachmentsSerializerHelper

  attributes :id,
             :name,
             :app_path,
             :grade_protection_level,
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

  attribute :current_user do |object, params|
    user_level = params[:current_user] ? 1 : 0
    user_level = object.user_crag_declaration.equivalent_level if object.user_crag_declaration
    {
      grade_protection: {
        level: user_level,
        required_level: object.grade_protection_level,
        need_level_up: object.grade_protection_level > user_level
      }
    }
  end

  def self.cover_attachment(object)
    object.photo_id.present? ? object.attachment_object(object.photo.picture, "Crag_cover") : object.attachment_object(object.static_map, "Crag_cover")
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
