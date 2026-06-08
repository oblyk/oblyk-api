# frozen_string_literal: true

class HistorizeTownsAroundJob < ApplicationJob
  queue_as :low

  def perform(latitude, longitude, request_date)
    Town
      .where('updated_at < ?', request_date)
      .where(
        '(population BETWEEN 0 AND 10000 AND ST_DISTANCE_SPHERE(POINT(towns.longitude, towns.latitude), POINT(:longitude, :latitude)) < 10000)
        OR (population BETWEEN 10001 AND 25000 AND ST_DISTANCE_SPHERE(POINT(towns.longitude, towns.latitude), POINT(:longitude, :latitude)) < 15000)
        OR (population BETWEEN 25001 AND 50000 AND ST_DISTANCE_SPHERE(POINT(towns.longitude, towns.latitude), POINT(:longitude, :latitude)) < 20000)
        OR (population > 50000 AND ST_DISTANCE_SPHERE(POINT(towns.longitude, towns.latitude), POINT(:longitude, :latitude)) < 30000)',
        latitude: latitude,
        longitude: longitude
      )
      .find_each do |town|
      HistorizeTownJob.perform_later town.id
    end
  end
end
