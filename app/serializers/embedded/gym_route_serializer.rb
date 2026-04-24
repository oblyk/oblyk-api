# frozen_string_literal: true

module Embedded
  class GymRouteSerializer < BaseSerializer
    include AttachmentsSerializerHelper

    belongs_to :gym_sector, serializer: Embedded::GymSectorSerializer
    has_many :videos, as: :viewable, serializer: Embedded::VideoSerializer, lazy_load_data: true

    attributes :id,
               :name,
               :app_path,
               :height,
               :description,
               :climbing_type,
               :opened_at,
               :dismounted_at,
               :hold_colors,
               :tag_colors,
               :sections,
               :difficulty_appreciation,
               :note,
               :note_count,
               :ascents_count,
               :sections_count,
               :gym_sector_id,
               :points,
               :level_index,
               :level_length,
               :level_color,
               :points_to_s,
               :grade_to_s,
               :gym_route_cover_id,
               :anchor_number,
               :thumbnail_position,
               :calculated_thumbnail_position,
               :votes,
               :updated_at,
               :all_comments_count,
               :videos_count,
               :sub_level,
               :sub_level_max

    attribute :dismounted, &:dismounted?

    attribute :text_contrast_color do |object|
      object.gym_openers.map(&:name).join(', ')
    end

    attribute :likes_count do |object|
      object.likes_count&.positive? ? object.likes_count : nil
    end

    attribute :gym_sector_name do |object|
      object.gym_sector.name
    end

    attribute :gym_route_cover do |object, params|
      if params.fetch(:include_gym_route_cover, false) == true
        {
          metadata: object.gym_route_cover&.picture ? object.gym_route_cover.picture.metadata : nil,
          original_file_path: object.gym_route_cover&.picture ? object.gym_route_cover.original_file_path : nil,
          attachments: {
            picture: object.attachment_object(object.gym_route_cover&.picture, 'GymRouteCover_picture')
          }
        }
      end
    end

    attribute :cover_metadata do |object, params|
      if params.fetch(:include_cover_metadata, false) == true
        object.gym_route_cover&.picture ? object.gym_route_cover.picture.metadata : nil
      end
    end

    attribute :grade_gap do |object|
      {
        max_grade_value: object.max_grade_value,
        min_grade_value: object.min_grade_value,
        max_grade_text: object.max_grade_text,
        min_grade_text: object.min_grade_text
      }
    end

    def self.thumbnail_attachment(object)
      object.attachment_object(object.thumbnail)
    end

    def self.avatar_attachment(object)
      thumbnail_attachment(object)
    end
  end
end
