# frozen_string_literal: true

module Elevable
  extend ActiveSupport::Concern

  included do
    before_save { init_elevation }
  end

  def api_elevation
    elevation = GoogleMapApi.elevations([{ latitude: latitude, longitude: longitude }])
    return nil unless elevation

    elevation.first['elevation'].round
  end

  def init_elevation
    return if latitude.blank? || longitude.blank?

    self.elevation = api_elevation if latitude_changed? || longitude_changed?
  end

  def update_elevation
    return if latitude.blank? || longitude.blank?

    update_column :elevation, api_elevation
  end
end
