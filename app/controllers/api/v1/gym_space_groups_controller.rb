# frozen_string_literal: true

module Api
  module V1
    class GymSpaceGroupsController < ApiController
      include Gymable
      before_action :set_gym_space_group, except: %i[index create]
      before_action -> { can? GymRole::MANAGE_SPACE }, except: %i[index show]

      def index
        render json: @gym.gym_space_groups.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @gym_space_group.detail_to_json, status: :ok
      end

      def create
        @gym_space_group = GymSpaceGroup.new(gym_space_group_params)
        @gym_space_group.gym = @gym
        if @gym_space_group.save
          render json: @gym_space_group.detail_to_json, status: :ok
        else
          render json: { error: @gym_space_group.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_space_group.update(gym_space_group_params)
          render json: @gym_space_group.detail_to_json, status: :ok
        else
          render json: { error: @gym_space_group.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_space_group.destroy
          head :no_content
        else
          render json: { error: @gym_space_group.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym_space_group
        @gym_space_group = GymSpaceGroup.find params[:id]
      end

      def gym_space_group_params
        params.require(:gym_space_group).permit(
          :name,
          :order,
          gym_space_ids: []
        )
      end
    end
  end
end
