# frozen_string_literal: true

module Api
  module V1
    class CragsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_crag, only: %i[show update destroy]

      def index
        @crags = Crag.includes(:user, :crag_sectors).all
      end

      def show; end

      def create
        @crag = Crag.new(crag_params)
        @crag.user = @current_user
        if @crag.save
          render 'api/v1/crags/show'
        else
          render json: { error: @crag.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @crag.update(crag_params)
          render 'api/v1/crags/show'
        else
          render json: { error: @crag.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @crag.delete
          render json: {}, status: :ok
        else
          render json: { error: @crag.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_crag
        @crag = Crag.includes(:user, :crag_sectors).find params[:id]
      end

      def crag_params
        params.require(:crag).permit(
          :name,
          :rain,
          :sun,
          :latitude,
          :longitude,
          :code_country,
          :country,
          :city,
          :region,
          :north,
          :north_east,
          :east,
          :south_east,
          :south,
          :south_west,
          :west,
          :north_west,
          :summer,
          :autumn,
          :winter,
          :spring,
          :photo_id,
          rocks: %i[name]
        )
      end
    end
  end
end
