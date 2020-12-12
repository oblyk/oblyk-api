# frozen_string_literal: true

module Api
  module V1
    class GymSpacesController < ApiController
      include Gymable
      skip_before_action :protected_by_session, only: %i[show index]
      skip_before_action :protected_by_gym_administrator, only: %i[show index]
      before_action :set_gym_space, except: %i[index]

      def index
        @gym_spaces = @gym.gym_spaces
      end

      def show; end

      def create
        @gym_space = GymSpace.new(gym_space_params)
        @gym_space.gym = @gym
        if @gym_space.save
          render 'api/v1/gym_spaces/show'
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_space.update(gym_space_params)
          render 'api/v1/gym_spaces/show'
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_space.delete
          render json: {}, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def publish
        if @gym_space.publish!
          render 'api/v1/gym_spaces/show'
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def unpublish
        if @gym_space.unpublish!
          render 'api/v1/gym_spaces/show'
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
    end
  end
end
