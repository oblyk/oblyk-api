# frozen_string_literal: true

module Api
  module V1
    class GymSectorsController < ApiController
      include Gymable
      skip_before_action :protected_by_session, only: %i[show index]
      skip_before_action :protected_by_gym_administrator, only: %i[show index]
      before_action :set_gym_space
      before_action :set_gym_sector, only: %i[show update destroy dismount_routes]

      def index
        @gym_sectors = @gym_space.gym_sectors
      end

      def show; end

      def create
        @gym_sector = GymSector.new(gym_sector_params)
        @gym_sector.gym_space = @gym_space
        if @gym_sector.save
          render 'api/v1/gym_sectors/show'
        else
          render json: { error: @gym_sector.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_sector.update(gym_sector_params)
          render 'api/v1/gym_sectors/show'
        else
          render json: { error: @gym_sector.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_sector.delete
          render json: {}, status: :ok
        else
          render json: { error: @gym_sector.errors }, status: :unprocessable_entity
        end
      end

      def dismount_routes
        routes = GymRoute.mounted.where(gym_sector: @gym_sector)
        routes.each(&:dismount!)
        render 'api/v1/gym_sectors/show'
      end

      private

      def set_gym_sector
        @gym_sector = GymSector.find params[:id]
      end

      def set_gym_space
        @gym_space = GymSpace.find params[:gym_space_id]
      end

      def gym_sector_params
        params.require(:gym_sector).permit(
          :name,
          :description,
          :group_sector_name,
          :climbing_type,
          :height,
          :banner_bg_color,
          :polygon,
          :gym_grade_id,
          :can_be_more_than_one_pitch
        )
      end
    end
  end
end
