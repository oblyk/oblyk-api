# frozen_string_literal: true

class SprayWallSerializer < BaseSerializer
  include AttachmentsSerializerHelper

  belongs_to :gym
  belongs_to :gym_sector, optional: true
  belongs_to :gym_space, optional: true
  has_many :spray_wall_holds, lazy_load_data: true

  attributes :id,
             :name,
             :title,
             :number,
             :draft,
             :opened_at,
             :picture_height,
             :picture_width,
             :archived_at,
             :app_path,
             :spray_wall_holds_count
             :spray_wall_routes_count

  def self.picture_attachment(object)
    object.attachment_object(object.picture)
  end

  def self.avatar_attachment(object)
    picture_attachment(object)
  end
end
