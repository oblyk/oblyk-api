# frozen_string_literal: true

module Api
  module V1
    class SprayWallHoldsController < ApiController
      include Gymable

      skip_before_action :protected_by_session, only: %i[index show]
      skip_before_action :protected_by_gym_administrator, only: %i[show index]
      before_action :set_spray_wall
      before_action :set_spray_wall_hold, except: %i[index show create]
      before_action -> { can? GymRole::MANAGE_OPENING }, except: %i[index show]

      def index
        render json: serializer(SprayWallHoldSerializer, @spray_wall.spray_wall_holds), status: :ok
      end

      def show
        render json: serializer(SprayWallHoldSerializer, @spray_wall_hold), status: :ok
      end

      def create
        spray_wall_hold = SprayWallHold.new(spray_wall_hold_params)
        spray_wall_hold.spray_wall = @spray_wall
        if spray_wall_hold.save
          head :no_content
        else
          render json: { error: spray_wall_hold.errors }, status: :unprocessable_content
        end
      end

      def update
        if @spray_wall_hold.update(spray_wall_hold_params)
          head :no_content
        else
          render json: { error: @spray_wall_hold.errors }, status: :unprocessable_content
        end
      end

      def destroy
        if @spray_wall_hold.destroy
          head :no_content
        else
          render json: { error: @spray_wall_hold.errors }, status: :unprocessable_content
        end
      end

      private

      def set_spray_wall
        @spray_wall = @gym.spray_walls.find params[:spray_wall_id]
      end

      def set_spray_wall_hold
        @spray_wall_hold = @spray_wall.spray_wall_holds.find params[:id]
      end

      def spray_wall_hold_params
        { points: params.require(:spray_wall_hold).fetch(:points, []) }
      end
    end
  end
end
