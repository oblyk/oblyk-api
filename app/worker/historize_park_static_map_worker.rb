# frozen_string_literal: true

class HistorizeParkStaticMapWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform(park_id)
    park = Park.find park_id

    # static map
    url = "https://api.mapbox.com/styles/v1/#{ENV['MAPBOX_STATIC_MAP_STYLE']}/static/pin-l+2e3436(#{park.longitude},#{park.latitude})/#{park.longitude},#{park.latitude},13/200x200?access_token=#{ENV['MAPBOX_TOKEN']}"
    mapbox_static_map = URI.open(url)
    park.static_map.attach(io: mapbox_static_map, filename: "#{park.id}-static-park-map.png", content_type: 'image/png')

    park.save
  end
end
