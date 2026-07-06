# frozen_string_literal: true

module Api
  module V1
    class TownsController < ApiController
      before_action :set_town, only: %i[show geo_json]

      def search
        query = params.fetch(:query, nil)
        head :no_content && return if query.blank?

        page = params.fetch(:page, 1).to_i
        per_page = params.fetch(:per_page, 25).to_i
        department_id = params.fetch(:department_id, nil)

        hits = Town.includes(department: :country)
        hits = if department_id.present?
                 hits.search(query, filter: "department_id = #{department_id}", page: page, hits_per_page: per_page)
               else
                 hits.search(query, page: page, hits_per_page: per_page)
               end

        serializer = serializer(
          TownSerializer,
          hits,
          {
            include: %i[department],
            meta: {
              query: query,
              current_page: hits.current_page,
              total_pages: hits.total_pages,
              total_count: hits.total_count,
              next_page: hits.next_page,
              prev_page: hits.prev_page
            }
          }
        )
        render json: serializer, status: :ok
      end

      def geo_search
        latitude = params[:latitude]
        longitude = params[:longitude]
        dist = params.fetch(:dist, 10)

        render json: Town.geo_search(latitude, longitude, dist).map(&:summary_to_json), status: :ok
      end

      def show
        around_dist = params.fetch(:dist, @town.default_dist)
        historize_version = @town.town_json_objects.find_by dist: @town.default_dist, version_date: @town.updated_at
        data = historize_version&.json_object || @town.detail_to_json(around_dist)
        data[:date_version] = @town.updated_at
        render json: data, status: :ok
      end

      def geo_json
        minimalistic = params.fetch(:minimalistic, false) != false
        features = []
        @town.dist_around = params.fetch(:dist, @town.default_dist)

        # Crags
        crags = minimalistic ? @town.crags : @town.crags.includes(photo: { picture_attachment: :blob })
        crags.find_each do |crag|
          features << crag.to_geo_json(minimalistic: minimalistic)
        end

        # Gyms
        gyms = @town.gyms.select(%i[id name longitude latitude updated_at]).includes(banner_attachment: :blob)
        gyms.find_each do |gym|
          features << gym.to_geo_json
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

      private

      def set_town
        @town = Town.find_by slug_name: params[:id]

        head :not_found unless @town
      end
    end
  end
end
