# frozen_string_literal: true

module Api
  module V1
    class TickListsController < ApiController
      before_action :protected_by_session, only: %i[index create destroy]
      before_action :set_tick_list, only: %i[destroy]

      def index
        @tick_lists = TickList.where user: @current_user
      end

      def create
        @tick_list = TickList.new(tick_list_params)
        @tick_list.user = @current_user
        if @tick_list.save
          render 'api/v1/tick_lists/show'
        else
          render json: { error: @tick_list.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @tick_list.delete
          render json: {}, status: :ok
        else
          render json: { error: @tick_list.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_tick_list
        @tick_list = TickList.find params[:id]
      end

      def tick_list_params
        params.require(:tick_list).permit(
          :crag_route_id
        )
      end
    end
  end
end
