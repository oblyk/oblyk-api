# frozen_string_literal: true

module Embedded
  class GymSpaceSerializer < BaseSerializer
    include AttachmentsSerializerHelper

    has_many :gym_sectors, serializer: Embedded::GymSectorSerializer

    attributes :id,
               :name,
               :svg_sectors,
               :sectors_color,
               :representation_type,
               :three_d_gltf_url,
               :three_d_parameters,
               :three_d_position,
               :three_d_scale,
               :three_d_rotation,
               :three_d_camera_position,
               :three_d_label_options,
               :scheme_height,
               :scheme_width

    attribute :text_contrast_color do |object|
      Color.black_or_white_rgb(object.sectors_color || 'rgb(0,0,0)')
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
end
