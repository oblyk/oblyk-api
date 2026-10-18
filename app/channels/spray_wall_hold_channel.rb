# frozen_string_literal: true

class SprayWallHoldChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    spray_wall = SprayWall.find params[:spray_wall_id]
    stream_from "spray_wall_#{spray_wall.id}.spray_wall_hold"
  end

  def unsubscribed
    stop_all_streams
  end
end
