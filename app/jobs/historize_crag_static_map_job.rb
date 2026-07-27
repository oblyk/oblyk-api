# frozen_string_literal: true

require "net/http"

class HistorizeCragStaticMapJob < ApplicationJob
  queue_as :default

  def perform(crag_id)
    crag = Crag.find crag_id

    # static map
    url = "https://api.mapbox.com/styles/v1/#{ENV.fetch('MAPBOX_STATIC_MAP_STYLE', nil)}/static/pin-l+2e3436(#{crag.longitude},#{crag.latitude})/#{crag.longitude},#{crag.latitude},15/1000x750?access_token=#{ENV.fetch('MAPBOX_TOKEN', nil)}"
    response = Net::HTTP.get_response(URI.parse(url))
    raise "Failed to fetch map: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    crag.static_map.attach(io: StringIO.new(response.body), filename: "#{crag.slug_name}-static-map.png", content_type: "image/png")

    # large static map
    banner_url = "https://api.mapbox.com/styles/v1/#{ENV.fetch('MAPBOX_STATIC_MAP_STYLE', nil)}/static/pin-l+2e3436(#{crag.longitude},#{crag.latitude})/#{crag.longitude},#{crag.latitude},11/1070x802?access_token=#{ENV.fetch('MAPBOX_TOKEN', nil)}"
    response = Net::HTTP.get_response(URI.parse(banner_url))
    raise "Failed to fetch map: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    crag.static_map_banner.attach(io: StringIO.new(response.body), filename: "#{crag.slug_name}-static-banner-map.png", content_type: "image/png")

    crag.save
  end
end
