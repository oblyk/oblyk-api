# frozen_string_literal: true

class FetchUserChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "fetch_user_#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
