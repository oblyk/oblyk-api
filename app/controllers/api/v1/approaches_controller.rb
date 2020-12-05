# frozen_string_literal: true

module Api
  module V1
    class ApproachesController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_approach, only: %i[show update destroy]

      def index
        @approaches = Approach.where(crag_id: params[:crag_id])
      end

      def show; end

      def create
        @approach = Approach.new(approach_params)
        @approach.user = @current_user
        if @approach.save
          render 'api/v1/approaches/show'
        else
          render json: { error: @approach.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @approach.update(approach_params)
          render 'api/v1/approaches/show'
        else
          render json: { error: @approach.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @approach.delete
          render json: {}, status: :ok
        else
          render json: { error: @approach.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_approach
        @approach = Approach.find params[:id]
      end

      def approach_params
        params.require(:approach).permit(
          :description,
          :polyline,
          :length,
          :approach_type,
          :crag_id
        )
      end
    end
  end
end
