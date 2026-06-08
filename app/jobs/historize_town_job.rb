# frozen_string_literal: true

class HistorizeTownJob < ApplicationJob
  queue_as :low

  def perform(town_id)
    town = Town.find town_id
    town.historize!
  end
end
