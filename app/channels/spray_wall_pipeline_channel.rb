# frozen_string_literal: true

class SprayWallPipelineChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    spray_wall = SprayWall.find params[:spray_wall_id]
    stream_from "spray_wall_#{spray_wall.id}.spray_wall_pipline"
  end

  def unsubscribed
    stop_all_streams
  end
end
