# frozen_string_literal: true

class GoogleMapApi
  BASE_URL = 'https://maps.googleapis.com/maps/api'
  GOOGLE_KEY = ENV['GOOGLE_MAP_KEY']

  # @param [Array] coordinates
  def self.elevations(coordinates)
    float_coordinates = []
    coordinates.each do |coordinate|
      float_coordinates << "#{coordinate[:latitude].to_f},#{coordinate[:longitude].to_f}"
    end
    float_coordinates = float_coordinates.join('|')
    request = RestClient.get(
      "#{BASE_URL}/elevation/json",
      {
        params: {
          locations: float_coordinates,
          key: GOOGLE_KEY
        }
      }
    )

    return if request.code != 200

    JSON.parse(request.body)['results']
  rescue StandardError
    false
  end

  def self.places(query)
    request = RestClient.get(
      "#{BASE_URL}/place/findplacefromtext/json",
      {
        params: {
          input: query,
          inputtype: 'textquery',
          fields: 'formatted_address,name,geometry',
          key: GOOGLE_KEY
        }
      }
    )

    return if request.code != 200

    JSON.parse(request.body)['candidates']
  rescue StandardError
    false
  end

  def self.reverse_geocoding(lat, lng)
    request = RestClient.get(
      "#{BASE_URL}/geocode/json",
      {
        params: {
          latlng: "#{lat},#{lng}",
          key: GOOGLE_KEY,
          result_type: 'locality|postal_code'
        }
      }
    )
    return if request.code != 200

    JSON.parse(request.body)['results']
  rescue StandardError
    false
  end
end
