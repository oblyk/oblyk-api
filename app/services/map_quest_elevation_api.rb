# frozen_string_literal: true

class MapQuestElevationApi

  # @param [Array] coordinates
  def self.elevations(coordinates)
    float_coordinates = []
    coordinates.each do |coordinate|
      float_coordinates << coordinate[:latitude].to_f
      float_coordinates << coordinate[:longitude].to_f
    end
    float_coordinates = float_coordinates.join(',')
    request = RestClient.get(
      "https://open.mapquestapi.com/elevation/v1/profile?key=NRSFXtuN1vAqUGY3ACLy0rPbIS02pjGI&shapeFormat=raw&latLngCollection=#{float_coordinates}"
    )

    return if request.code != 200

    JSON.parse(request.body)['elevationProfile']
  rescue StandardError
    false
  end
end
