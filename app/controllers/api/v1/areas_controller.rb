# frozen_string_literal: true

module Api
  module V1
    class AreasController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_area, only: %i[show update destroy]

      def index
        @areas = Area.all
      end

      def show; end

      def create
        @area = Area.new(area_params)
        @area.user = @current_user
        if @area.save
          render 'api/v1/areas/show'
        else
          render json: { error: @area.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @area.update(area_params)
          render 'api/v1/areas/show'
        else
          render json: { error: @area.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @area.delete
          render json: {}, status: :ok
        else
          render json: { error: @area.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_area
        @area = Area.find params[:id]
      end

      def area_params
        params.require(:area).permit(
          :name
        )
      end
    end
  end
end
