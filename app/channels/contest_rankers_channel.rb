# frozen_string_literal: true

class ContestRankersChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    contest = Contest.find params[:contest_id]
    stream_from "contest_rankers_#{contest.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
