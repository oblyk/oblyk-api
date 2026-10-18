# frozen_string_literal: true

class SprayWallPipelineJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(pipeline_id)
    pipeline = SprayWallPipeline.find pipeline_id
    return if pipeline.canceled?

    pipeline.status = "ai_running"
    pipeline.save
    response = RoboflowApi.outline_holds(pipeline.spray_wall.picture_url)
    if response
      pipeline.body = response
      pipeline.status = "holds_creating"
      pipeline.save
      pipeline.create_holds_from_contours_json!
    else
      pipeline.status = "failed"
      pipeline.end_at = Time.zone.now
      pipeline.save
    end
  end
end
