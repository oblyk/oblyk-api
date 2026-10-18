# frozen_string_literal: true

class SprayWallPipeline < ApplicationRecord
  belongs_to :spray_wall

  before_validation :set_status

  after_save :broadcast

  validates :status, inclusion: { in: %w[initialised queuing ai_running holds_creating completed failed cancelled] }

  def run!
    self.status = "queuing"
    self.start_at = Time.zone.now
    save
    SprayWallPipelineJob.set(wait: 1.second).perform_later(self.id)
  end

  def run?
    %w[completed failed cancelled].exclude? status
  end

  def create_holds_from_contours_json!
    picture_height = spray_wall.picture_height
    picture_width = spray_wall.picture_width
    body["contours_json"].each do |contour_json|
      points = []
      contour_json["vertices"].each do |xy|
        points << [ xy["x"].to_f / picture_width, xy["y"].to_f / picture_height ]
      end
      spray_wall.spray_wall_holds << SprayWallHold.new(points: points, source: "ai_segmentation")
    end
    self.end_at = Time.zone.now
    self.status = "completed"
    save
  end

  def canceled?
    status == "cancelled"
  end

  def broadcast
    data = SprayWallPipelineSerializer.new(self).serializable_hash
    ActionCable.server.broadcast "spray_wall_#{spray_wall_id}.spray_wall_pipline", data
  end

  private

  def set_status
    self.status ||= "initialised"
  end
end
