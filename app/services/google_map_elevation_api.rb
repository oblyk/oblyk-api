# frozen_string_literal: true

class GoogleMapElevationApi

  # @param [Array] coordinates
  def self.elevations(coordinates)
    float_coordinates = []
    coordinates.each do |coordinate|
      float_coordinates << "#{coordinate[:latitude].to_f},#{coordinate[:longitude].to_f}"
    end
    float_coordinates = float_coordinates.join('|')
    request = RestClient.get(
      "https://maps.googleapis.com/maps/api/elevation/json?locations=#{float_coordinates}&key=#{ENV['GOOGLE_MAP_KEY']}"
    )

    return if request.code != 200

    JSON.parse(request.body)['results']
  rescue StandardError
    false
  end
end
