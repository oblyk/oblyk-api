# frozen_string_literal: true

module Api
  module V1
    class RockBarsController < ApiController
      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update]
      before_action :set_crag, only: %i[index create update]
      before_action :set_rock_bar, only: %i[show update]

      def index
        render json: @crag.rock_bars.all.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @rock_bar.detail_to_json, status: :ok
      end

      def create
        @rock_bar = RockBar.new(bar_rock_params)
        @rock_bar.polyline = params[:rock_bar][:polyline]
        @rock_bar.crag = @crag
        if @rock_bar.save
          render json: @rock_bar.detail_to_json, status: :ok
        else
          render json: { error: @rock_bar.errors }, status: :unprocessable_entity
        end
      end

      def update
        @rock_bar.polyline = params[:rock_bar][:polyline]
        if @rock_bar.update(bar_rock_params)
          render json: @rock_bar.detail_to_json, status: :ok
        else
          render json: { error: @rock_bar.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @rock_bar.destroy
          render json: {}, status: :ok
        else
          render json: { error: @crag.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_crag
        @crag = Crag.find params[:crag_id]
      end

      def set_rock_bar
        @rock_bar = RockBar.find params[:id]
      end

      def bar_rock_params
        params.require(:rock_bar).permit(
          :crag_sector_id
        )
      end
    end
  end
end
