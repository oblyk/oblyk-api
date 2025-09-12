# frozen_string_literal: true

module Api
  module V1
    class DepartmentsController < ApiController
      before_action :set_country
      before_action :set_department, only: %i[show route_figures geo_json]

      def index
        departments = @country.departments
                              .select(
                                :id,
                                :name,
                                :slug_name,
                                :department_number,
                                :name_prefix_type,
                                :in_sentence_prefix_type,
                                :country_id,
                                :updated_at
                              )
                              .order(:department_number)
        render json: departments.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @department.detail_to_json, status: :ok
      end

      def route_figures
        render json: @department.route_figures, status: :ok
      end

      def geo_json
        minimalistic = params.fetch(:minimalistic, false) != false
        features = []

        # Crags
        if params.fetch(:crags, 'true') == 'true'
          crags = minimalistic ? @department.crags : @department.crags.includes(photo: { picture_attachment: :blob })
          Climb::CRAG_LIST.each do |climbing_type|
            crags = crags.where(climbing_type => true) if climbing_type == params[:climbing_type]
          end
          crags.find_each do |crag|
            features << crag.to_geo_json(minimalistic: minimalistic)
          end
        end

        # Gyms
        if params.fetch(:gyms, 'true') == 'true'
          gyms = @department.gyms.select(%i[id name longitude latitude updated_at]).includes(banner_attachment: :blob)
          gyms.find_each do |gym|
            features << gym.to_geo_json
          end
        end

        features << @department.to_geo_json if @department.geo_polygon

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

      def set_country
        @country = Country.find_by code_country: params[:country_id]
      end

      def set_department
        @department = @country.departments.find_by department_number: params[:id]
      end
    end
  end
end
