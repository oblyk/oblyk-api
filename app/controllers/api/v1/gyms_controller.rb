# frozen_string_literal: true

module Api
  module V1
    class GymsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update add_banner add_logo]
      before_action :set_gym, only: %i[show update destroy add_banner add_logo]
      before_action :protected_by_administrator, only: %i[update add_banner add_logo]

      def index
        @gyms = Gym.all
      end

      def geo_json
        features = []

        Gym.all.each do |gym|
          features << {
            type: 'Feature',
            properties: {
              id: gym.id,
              name: gym.name,
              slug_name: gym.slug_name,
              climbing_key: gym.climbing_key,
              icon: "gym-marker-#{gym.climbing_key}",
              localization: "#{gym.city}, #{gym.region}",
              bouldering: gym.bouldering,
              sport_climbing: gym.sport_climbing,
              pan: gym.pan,
              fun_climbing: gym.fun_climbing,
              training_space: gym.training_space,
              map_thumbnail_url: gym.banner.present? ? gym.thumbnail_banner_url : nil
            },
            geometry: { type: 'Point', "coordinates": [Float(gym.longitude), Float(gym.latitude), 0.0] }
          }
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

      def show; end

      def create
        @gym = Gym.new(gym_params)
        @gym.user = @current_user
        if @gym.save
          render 'api/v1/gyms/show'
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym.update(gym_params)
          render 'api/v1/gyms/show'
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def add_banner
        if @gym.update(banner_params)
          render 'api/v1/gyms/show'
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def add_logo
        if @gym.update(logo_params)
          render 'api/v1/gyms/show'
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym.delete
          render json: {}, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      private

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
