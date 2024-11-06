# frozen_string_literal: true

module Api
  module V1
    class LocalitiesController < ApiController
      before_action :set_locality, only: %i[show climbers]

      def show
        render json: @locality.detail_to_json, status: :ok
      end

      def geo_json
        last_updated_locality = Locality.order(updated_at: :desc).first

        json_features = Rails.cache.fetch("#{last_updated_locality.cache_key_with_version}/localities_geo_json", expires_in: 1.week) do
          geo_json_features
        end

        json = {
          type: 'FeatureCollection',
          crs: {
            type: 'name',
            properties: {
              name: 'urn'
            }
          },
          features: json_features
        }
        render json: json, status: :ok
      end

      def climbers
        page = params.fetch(:page, 1)
        json = []
        localities = @locality.locality_users
                              .joins(:user)
                              .activated
                              .where('users.last_activity_at > ?', Date.current - 3.years)

        level = params.fetch(:level, nil)
        if level
          localities = localities.where(
            '(users.grade_min IS NULL OR users.grade_min <= :level) AND (users.grade_max IS NULL OR users.grade_max >= :level)',
            level: level
          )
        end

        partner_search = params.fetch(:partner_search, nil)
        if partner_search.to_s == 'true'
          localities = localities.where(users: { partner_search: true })
                                 .where(partner_search: true)
        end

        climbing_type = params.fetch(:climbing_type, nil)
        climbing_type = Climb::ALL_LIST.include?(climbing_type.to_s) ? climbing_type : nil
        localities = localities.where(users: { climbing_type => true }) if climbing_type

        localities.page(page)
                  .order('users.last_activity_at DESC, id')
                  .each do |locality_user|
          json << locality_user.local_to_json
        end
        render json: json, status: :ok
      end

      private

      def geo_json_features
        features = []
        Locality.with_partner_search.select(
          :id,
          :name,
          :partner_search_users_count,
          :local_sharing_users_count,
          :distinct_users_count,
          :latitude,
          :longitude
        ).find_each do |climber_place|
          features << climber_place.to_geo_json
        end
        features
      end

      def set_locality
        @locality = Locality.find params[:id]
      end
    end
  end
end
