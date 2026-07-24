# frozen_string_literal: true

class HistorizeParkStaticMapJob < ApplicationJob
  queue_as :default

  def perform(park_id)
    park = Park.find park_id

    # static map
    url = "https://api.mapbox.com/styles/v1/#{ENV.fetch('MAPBOX_STATIC_MAP_STYLE', nil)}/static/pin-l+2e3436(#{park.longitude},#{park.latitude})/#{park.longitude},#{park.latitude},13/200x200?access_token=#{ENV.fetch('MAPBOX_TOKEN', nil)}"
    response = Net::HTTP.get_response(URI.parse(url))
    raise "Failed to fetch map: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    park.static_map.attach(io: StringIO.new(response.body), filename: "#{park.id}-static-park-map.png", content_type: 'image/png')
    park.save
  end
end
