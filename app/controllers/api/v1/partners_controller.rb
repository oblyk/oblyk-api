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

      def figures
        climbers = User.where(partner_search: true)
        render json: {
          count_global: climbers.count,
          count_last_week: climbers.where('partner_search_activated_at > ?', DateTime.current - 1.week).count
        }
      end
    end
  end
end
