# frozen_string_literal: true

module Api
  module V1
    class GymsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update add_banner add_logo routes_count routes]
      before_action :set_gym, only: %i[show versions update destroy add_banner add_logo routes_count routes]
      before_action :protected_by_administrator, only: %i[update add_banner add_logo routes_count routes]

      def index
        gyms = Gym.all
        render json: gyms.map(&:summary_to_json), status: :ok
      end

      def search
        query = params[:query]
        gyms = Gym.search(query).records
        render json: gyms.map(&:summary_to_json), status: :ok
      end

      def geo_json
        render json: {
          type: 'FeatureCollection',
          crs: {
            type: 'name',
            properties: {
              name: 'urn'
            }
          },
          features: geo_json_features
        }, status: :ok
      end

      def show
        render json: @gym.detail_to_json, status: :ok
      end

      def gyms_around
        distance = params.fetch(:distance, 20)
        gyms = Gym.geo_search(params[:latitude], params[:longitude], distance)
        render json: gyms.map(&:summary_to_json), status: :ok
      end

      def versions
        versions = @gym.versions
        render json: OblykVersion.index(versions), status: :ok
      end

      def create
        @gym = Gym.new(gym_params)
        @gym.user = @current_user
        if @gym.save
          render json: @gym.detail_to_json, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym.update(gym_params)
          render json: @gym.detail_to_json, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def add_banner
        if @gym.update(banner_params)
          render json: @gym.detail_to_json, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def add_logo
        if @gym.update(logo_params)
          render json: @gym.detail_to_json, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym.destroy
          render json: {}, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def routes_count
        render json: @gym.gym_routes.mounted.count, status: :ok
      end

      def routes
        gym_routes = if params.fetch(:dismounted, 'false') == 'true'
                       @gym.gym_routes.dismounted
                     else
                       @gym.gym_routes.mounted
                     end
        render json: gym_routes.map(&:summary_to_json), status: :ok
      end

      private

      def geo_json_features
        features = []

        Gym.all.each do |gym|
          features << gym.to_geo_json
        end
        features
      end

      def set_gym
        @gym = Gym.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def gym_params
        params.require(:gym).permit(
          :name,
          :description,
          :address,
          :postal_code,
          :code_country,
          :country,
          :city,
          :big_city,
          :region,
          :email,
          :phone_number,
          :web_site,
          :bouldering,
          :sport_climbing,
          :pan,
          :fun_climbing,
          :training_space,
          :latitude,
          :longitude
        )
      end

      def banner_params
        params.require(:gym).permit(
          :banner
        )
      end

      def logo_params
        params.require(:gym).permit(
          :logo
        )
      end
    end
  end
end
