# frozen_string_literal: true

class SprayWall < ApplicationRecord
  include Archivable
  include AttachmentResizable

  belongs_to :gym
  belongs_to :gym_sector, optional: true
  belongs_to :gym_space, optional: true
  has_many :spray_wall_holds
  has_many :spray_wall_pipelines

  before_create :set_number

  has_one_attached :picture


  def title
    name || "Spray Wall ##{number}"
  end

  def app_path
    "/gyms/#{gym_id}/spray-walls/#{id}"
  end

  def set_picture_dimension!
    return unless picture.attached?

    meta = ActiveStorage::Analyzer::ImageAnalyzer::Vips.new(picture.blob).metadata

    self.picture_height = meta[:height]
    self.picture_width = meta[:width]
    save
  end

  def picture_url
    return nil unless picture.attached?

    if Rails.application.config.cdn_storage_services.include? Rails.application.config.active_storage.service
      # Use CLOUDFLARE R2 CDN
      "#{ENV.fetch('CLOUDFLARE_R2_DOMAIN', ENV.fetch('OBLYK_API_URL', nil))}/#{picture&.blob&.key}"

    else
      # Use local active storage
      "#{ENV.fetch('OBLYK_API_URL', nil)}#{Rails.application.routes.url_helpers.polymorphic_url(picture, only_path: true)}"
    end
  end

  def broadcast
    data = {
      spray_wall: SprayWallSerializer.new(self).serializable_hash,
      spray_wall_pipelines: SprayWallPipelineSerializer.new(spray_wall_pipelines).serializable_hash
    }
    SprayWallEditorChannel.broadcast self, data
  end

  private

  def set_number
    self.number = (gym.spray_walls.maximum(:number) || 0) + 1
  end
end
