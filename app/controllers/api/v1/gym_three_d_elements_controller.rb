# frozen_string_literal: true

module Api
  module V1
    class GymThreeDElementsController < ApiController
      include Gymable

      skip_before_action :protected_by_session, only: %i[show index]
      skip_before_action :protected_by_gym_administrator, only: %i[show index]
      before_action :set_gym_space
      before_action :set_gym_three_d_element, except: %i[index create]
      before_action -> { can? GymRole::MANAGE_SPACE }, except: %i[index show]

      def index
        gym_three_d_elements = if @gym_space
                                 GymThreeDElement.where gym: @gym, gym_space: @gym_space
                               else
                                 GymThreeDElement.where gym: @gym
                               end
        render json: gym_three_d_elements.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @gym_three_d_element.detail_to_json, status: :ok
      end

      def create
        @gym_three_d_element = GymThreeDElement.new gym_three_d_element_params
        @gym_three_d_element.gym = @gym
        @gym_three_d_element.three_d_rotation = { x: 0, y: 0, z: 0 }
        @gym_three_d_element.gym_space = @gym_space if @gym_space
        if @gym_three_d_element.save
          render json: @gym_three_d_element.detail_to_json, status: :ok
        else
          render json: { error: @gym_three_d_element.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_three_d_element.update gym_three_d_element_params
          render json: @gym_three_d_element.detail_to_json, status: :ok
        else
          render json: { error: @gym_three_d_element.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_three_d_element.destroy
          head :no_content
        else
          render json: { error: @gym_three_d_element.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym_space
        @gym_space = @gym.gym_spaces.find_by id: params[:id]
      end

      def set_gym_three_d_element
        @gym_three_d_element = GymThreeDElement.find params[:id]
      end

      def gym_three_d_element_params
        params.require(:gym_three_d_element).permit(
          :three_d_scale,
          :message,
          :url,
          :gym_three_d_asset_id,
          three_d_position: %i[x y z],
          three_d_rotation: %i[x y z]
        )
      end
    end
  end
end
