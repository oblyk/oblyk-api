# frozen_string_literal: true

module Api
  module V1
    class PartnersController < ApiController
      before_action :protected_by_session, only: %i[partners_around]

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

      def partners_around
        distance = params.fetch(:distance, '20km')
        @users = User.partner_geo_search(params[:latitude], params[:longitude], distance).records
        render 'api/v1/users/index'
      end
    end
  end
end
