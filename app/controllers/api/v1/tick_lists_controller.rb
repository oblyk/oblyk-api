# frozen_string_literal: true

module Api
  module V1
    class TickListsController < ApiController
      before_action :protected_by_session, only: %i[index create destroy]
      before_action :set_tick_list, only: %i[destroy]

      def index
        tick_lists = TickList.where user: @current_user
        render json: tick_lists.map(&:summary_to_json), status: :ok
      end

      def create
        @tick_list = TickList.new(crag_route_id: tick_list_params)
        @tick_list.user = @current_user
        if @tick_list.save
          render json: @current_user.tick_list_to_a, status: :ok
        else
          render json: { error: @tick_list.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @tick_list.destroy
          render json: @current_user.tick_list_to_a, status: :ok
        else
          render json: { error: @tick_list.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_tick_list
        @tick_list = TickList.find_by crag_route_id: params[:crag_route_id]
      end

      def tick_list_params
        params.require(:crag_route_id)
      end
    end
  end
end
