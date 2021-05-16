# frozen_string_literal: true

class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "notification_#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
