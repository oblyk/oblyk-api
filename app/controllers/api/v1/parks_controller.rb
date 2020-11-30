# frozen_string_literal: true

module Api
  module V1
    class ParksController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_park, only: %i[show update destroy]

      def index
        @parks = Park.where(crag_id: params[:crag_id])
      end

      def show; end

      def create
        @park = Park.new(park_params)
        @park.user = @current_user
        if @park.save
          render 'api/v1/parks/show'
        else
          render json: { error: @park.errors }, status: :unauthorized
        end
      end

      def update
        if @park.update(park_params)
          render 'api/v1/parks/show'
        else
          render json: { error: @park.errors }, status: :unauthorized
        end
      end

      def destroy
        if @park.delete
          render json: {}, status: :ok
        else
          render json: { error: @park.errors }, status: :unauthorized
        end
      end

      private

      def set_park
        @park = Park.find params[:id]
      end

      def park_params
        params.require(:park).permit(
          :description,
          :latitude,
          :longitude,
          :crag_id
        )
      end
    end
  end
end
