# frozen_string_literal: true

module Api
  module V1
    class GymChainsController < ApiController
      include UploadVerification

      before_action :protected_by_session, only: %i[update add_banner add_logo]
      before_action :set_gym_chain, only: %i[gyms_geo_json show update add_banner add_logo]
      before_action :protected_by_administrator, except: %i[gyms_geo_json show]

      def gyms_geo_json
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
        render json: @gym_chain.detail_to_json, status: :ok
      end

      def update
        if @gym_chain.update(gym_chain_params)
          render json: @gym_chain.detail_to_json, status: :ok
        else
          render json: { error: @gym_chain.errors }, status: :unprocessable_entity
        end
      end

      def add_banner
        return unless verify_file banner_params[:banner], :image

        if @gym_chain.update(banner_params)
          render json: @gym_chain.detail_to_json, status: :ok
        else
          render json: { error: @gym_chain.errors }, status: :unprocessable_entity
        end
      end

      def add_logo
        return unless verify_file logo_params[:logo], :image

        if @gym_chain.update(logo_params)
          render json: @gym_chain.detail_to_json, status: :ok
        else
          render json: { error: @gym_chain.errors }, status: :unprocessable_entity
        end
      end

      private

      def geo_json_features
        features = []
        gyms = @gym_chain.gyms.select(%i[id name longitude latitude]).includes(banner_attachment: :blob)
        gyms.each do |gym|
          features << gym.to_geo_json
        end
        features
      end

      def set_gym_chain
        @gym_chain = GymChain.find_by slug_name: params[:id]
      end

      def protected_by_administrator
        forbidden if @gym_chain.gym_chain_administrators.where(user_id: @current_user.id).count.zero?
      end

      def gym_chain_params
        params.require(:gym_chain).permit(
          :name,
          :description
        )
      end

      def banner_params
        params.require(:gym_chain).permit(
          :banner
        )
      end

      def logo_params
        params.require(:gym_chain).permit(
          :logo
        )
      end
    end
  end
end
