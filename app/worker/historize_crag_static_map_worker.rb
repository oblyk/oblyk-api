# frozen_string_literal: true

class HistorizeCragStaticMapWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform(crag_id)
    crag = Crag.find crag_id

    # static map
    url = "https://api.mapbox.com/styles/v1/#{ENV['MAPBOX_STATIC_MAP_STYLE']}/static/pin-l+2e3436(#{crag.longitude},#{crag.latitude})/#{crag.longitude},#{crag.latitude},15/1000x750?access_token=#{ENV['MAPBOX_TOKEN']}"
    mapbox_static_map = URI.open(url)
    crag.static_map.attach(io: mapbox_static_map, filename: "#{crag.slug_name}-static-map.png", content_type: 'image/png')

    # large static map
    banner_url = "https://api.mapbox.com/styles/v1/#{ENV['MAPBOX_STATIC_MAP_STYLE']}/static/pin-l+2e3436(#{crag.longitude},#{crag.latitude})/#{crag.longitude},#{crag.latitude},11/1070x802?access_token=#{ENV['MAPBOX_TOKEN']}"
    mapbox_banner_static_map = URI.open(banner_url)
    crag.static_map_banner.attach(io: mapbox_banner_static_map, filename: "#{crag.slug_name}-static-banner-map.png", content_type: 'image/png')

    crag.save
  end
end
