# frozen_string_literal: true

module Api
  module V1
    class GymSpacesController < ApiController
      include Gymable
      skip_before_action :protected_by_session, only: %i[show index]
      skip_before_action :protected_by_gym_administrator, only: %i[show index]
      before_action :set_gym_space, except: %i[index create]

      def index
        gym_spaces = @gym.gym_spaces
        render json: gym_spaces.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @gym_space.detail_to_json, status: :ok
      end

      def create
        @gym_space = GymSpace.new(gym_space_params)
        @gym_space.gym = @gym
        if @gym_space.save
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_space.update(gym_space_params)
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_space.destroy
          render json: {}, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def publish
        if @gym_space.publish!
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def unpublish
        if @gym_space.unpublish!
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def add_banner
        if @gym_space.update(banner_params)
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def add_plan
        if @gym_space.update(plan_params)
          @gym_space.set_plan_dimension!
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym_space
        @gym_space = GymSpace.find params[:id]
      end

      def gym_space_params
        params.require(:gym_space).permit(
          :name,
          :description,
          :order,
          :climbing_type,
          :banner_color,
          :banner_bg_color,
          :banner_opacity,
          :scheme_bg_color,
          :scheme_height,
          :scheme_width,
          :latitude,
          :longitude,
          :gym_grade_id
        )
      end

      def banner_params
        params.require(:gym_space).permit(
          :banner
        )
      end

      def plan_params
        params.require(:gym_space).permit(
          :plan
        )
      end
    end
  end
end
