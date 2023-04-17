# frozen_string_literal: true

class OpenStreetMapApi
  BASE_URL = 'https://nominatim.openstreetmap.org'
  EMAIL = ENV['SMTP_USER_NAME']

  def self.search(query)
    request = RestClient.get(
      "#{BASE_URL}/search",
      {
        params: {
          q: query,
          format: 'json',
          addressdetails: 1,
          email: EMAIL
        }
      }
    )

    return if request.code != 200

    JSON.parse(request.body)
  rescue StandardError
    false
  end

  def self.reverse_geocoding(latitude, longitude)
    request = RestClient.get(
      "#{BASE_URL}/reverse",
      {
        params: {
          format: 'json',
          lat: latitude,
          lon: longitude,
          zoom: 13,
          addressdetails: 1,
          email: EMAIL
        }
      }
    )

    return if request.code != 200

    JSON.parse(request.body)
  rescue StandardError
    false
  end
end
