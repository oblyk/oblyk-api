# frozen_string_literal: true

class GymRouteSerializer < BaseSerializer
  include AttachmentsSerializerHelper

  has_many :gym_openers, lazy_load_data: true
  belongs_to :gym_space
  belongs_to :gym_sector
  belongs_to :gym, through: :gym_sector

  attributes :id,
             :name,
             :height,
             :description,
             :climbing_type,
             :opened_at,
             :dismounted_at,
             :polyline,
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
             :gym_route_cover_id,
             :anchor_number,
             :short_app_path,
             :thumbnail_position,
             :votes,
             :updated_at,
             :all_comments_count,
             :videos_count,
             :sub_level,
             :sub_level_max,
             :gym_space_app_path

  attribute :dismounted, &:dismounted?
  attribute :points_to_s, &:points_to_s
  attribute :grade_to_s, &:grade_to_s
  attribute :calculated_thumbnail_position, &:calculated_thumbnail_position

  attribute :gym_opener_ids do |object, params|
    include_attribute(params, :gym_opener_ids) ? object.gym_openers.map(&:id) : nil
  end

  attribute :gym_sector_name do |object|
    object.gym_sector.name
  end

  attribute :likes_count do |object|
    object.likes_count&.positive? ? object.likes_count : nil
  end

  attribute :cover_metadata do |object, params|
    object.gym_route_cover.picture.metadata if include_attribute(params, :cover_metadata) && object.gym_route_cover&.picture
  end

  attribute :gym_route_cover do |object, params|
    if include_attribute(params, :gym_route_cover)
      {
        metadata: object.gym_route_cover&.picture ? object.gym_route_cover.picture.metadata : nil,
        original_file_path: object.gym_route_cover&.picture ? object.gym_route_cover.original_file_path : nil,
        attachments: {
          picture: object.attachment_object(object.gym_route_cover&.picture, 'GymRouteCover_picture')
        }
      }
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

  attribute :history do |object|
    {
      created_at: object.created_at,
      updated_at: object.updated_at
    }
  end

  def self.thumbnail_attachment(object)
    object.attachment_object(object.thumbnail)
  end

  def self.avatar_attachment(object)
    thumbnail_attachment(object)
  end
end
