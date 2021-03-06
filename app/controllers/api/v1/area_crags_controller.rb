# frozen_string_literal: true

module Api
  module V1
    class AreaCragsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create destroy]
      before_action :set_area_crag, only: %i[destroy]

      def create
        area_crag = AreaCrag.new(area_crag_params)
        area_crag.user = @current_user
        @area = Area.find area_crag_params[:area_id]
        if area_crag.save
          render json: @area.detail_to_json, status: :ok
        else
          render json: { error: area_crag.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @area = @area_crag.area
        if @area_crag.destroy
          render json: @area.detail_to_json, status: :ok
        else
          render json: { error: @area_crag.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_area_crag
        @area_crag = AreaCrag.find params[:id]
      end

      def area_crag_params
        params.require(:area_crag).permit(
          :crag_id,
          :area_id
        )
      end
    end
  end
end
