# frozen_string_literal: true

class GymSpaceSerializer < BaseSerializer
  include AttachmentsSerializerHelper

  belongs_to :gym

  attributes :id,
             :name,
             :slug_name,
             :app_path,
             :description,
             :order,
             :climbing_type,
             :scheme_height,
             :scheme_width,
             :sectors_color,
             :gym_space_group_id,
             :anchor,
             :draft,
             :archived_at,
             :representation_type,
             :three_d_parameters,
             :three_d_label_options,
             :svg_sectors

  attribute :have_three_d, &:three_d?

  attribute :text_contrast_color do |object|
    Color.black_or_white_rgb(object.sectors_color || 'rgb(0,0,0)')
  end

  attribute :figures do |object, params|
    if params[:with_figures]
      routes_figures = object.gym_routes.mounted.select('MAX(opened_at) AS max_opened_at, COUNT(*) AS routes_count').first
      {
        routes_count: routes_figures[:routes_count],
        last_route_opened_at: routes_figures[:max_opened_at]
      }
    end
  end

  def self.banner_attachment(object)
    object.attachment_object(object.banner)
  end

  def self.plan_attachment(object)
    object.attachment_object(object.plan)
  end

  def self.three_d_picture_attachment(object)
    object.attachment_object(object.three_d_picture)
  end

  def self.avatar_attachment(object)
    if object.representation_type == '3d'
      three_d_picture_attachment(object)
    else
      plan_attachment(object)
    end
  end
end
