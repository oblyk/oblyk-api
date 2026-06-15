# frozen_string_literal: true

class OpenElevationApi

  # @param [Array] coordinates
  def self.elevations(coordinates)
    float_coordinates = []
    coordinates.each do |coordinate|
      float_coordinates << {
        latitude: coordinate[:latitude].to_f,
        longitude: coordinate[:longitude].to_f
      }
    end

    request = RestClient.post(
      'https://api.open-elevation.com/api/v1/lookup',
      { locations: float_coordinates }.to_json,
      { content_type: :json, accept: :json }
    )

    return if request.code != 200

    JSON.parse(request.body)['results']
  rescue StandardError
    false
  end
end
