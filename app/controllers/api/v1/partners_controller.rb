# frozen_string_literal: true

module Api
  module V1
    class PartnersController < ApiController
      def geo_json
        features = []

        User.partner_geolocable.each do |user|
          features << user.to_partner_geo_json
        end

        render json: {
          type: 'FeatureCollection',
          crs: {
            type: 'name',
            properties: {
              name: 'urn'
            }
          },
          features: features
        }, status: :ok
      end
    end
  end
end
