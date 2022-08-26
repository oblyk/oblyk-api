# frozen_string_literal: true

class HistorizeTownWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform(town_id)
    town = Town.find town_id
    town.historize!
  end
end
