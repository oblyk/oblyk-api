# frozen_string_literal: true

module Api
  module V1
    class GymSectorsController < ApiController
      include Gymable
      skip_before_action :protected_by_session, only: %i[show index]
      skip_before_action :protected_by_gym_administrator, only: %i[show index]
      before_action :set_gym_space
      before_action :set_gym_sector, only: %i[show update destroy dismount_routes last_routes_with_pictures delete_three_d_path]
      before_action -> { can? GymRole::MANAGE_SPACE }, except: %i[index show last_routes_with_pictures]

      def index
        gym_sectors = @gym_space.gym_sectors
        render json: gym_sectors.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @gym_sector.detail_to_json, status: :ok
      end

      def create
        @gym_sector = GymSector.new(gym_sector_params)
        @gym_sector.gym_space = @gym_space
        if @gym_sector.save
          render json: @gym_sector.detail_to_json, status: :ok
        else
          render json: { error: @gym_sector.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_sector.update(gym_sector_params)
          render json: @gym_sector.detail_to_json, status: :ok
        else
          render json: { error: @gym_sector.errors }, status: :unprocessable_entity
        end
      end

      def bulk_update
        sectors_params = gym_sectors_bulk_params[:gym_sectors]
        update_sectors = []
        errors = []

        sectors_params.each do |sector_params|
          sector = @gym_space.gym_sectors.find(sector_params[:id])
          sector.order = sector_params[:order]
          sector.name = sector_params[:name]
          sector.height = sector_params[:height]
          sector.linear_metre = sector_params[:linear_metre]
          sector.developed_metre = sector_params[:developed_metre]
          sector.category_name = sector_params[:category_name]
          sector.average_opening_time = sector_params[:average_opening_time]
          if sector.valid?
            update_sectors << sector
          else
            errors << sector.errors.full_messages
          end
        end

        if errors.size.positive?
          render json: { error: errors }, status: :unprocessable_entity
        else
          update_sectors.each(&:save)
        end
      end

      def destroy
        if @gym_sector.destroy
          head :no_content
        else
          render json: { error: @gym_sector.errors }, status: :unprocessable_entity
        end
      end

      def dismount_routes
        routes = GymRoute.mounted.where(gym_sector: @gym_sector)
        routes.each(&:dismount!)
        render json: @gym_sector.detail_to_json, status: :ok
      end

      def last_routes_with_pictures
        json_data = []
        gym_route_cover_ids = GymRoute.distinct.select(:gym_route_cover_id).mounted.where(gym_sector_id: @gym_sector.id).map(&:gym_route_cover_id)
        GymRouteCover.where(id: gym_route_cover_ids)
                     .order(created_at: :desc)
                     .limit(params.fetch(:limit, 5))
                     .each do |gym_route_cover|
          json_data << gym_route_cover.detail_to_json
        end
        render json: json_data, status: :ok
      end

      def delete_three_d_path
        @gym_sector.three_d_path = nil
        @gym_sector.save
        head :no_content
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
          :order,
          :min_anchor_number,
          :max_anchor_number,
          :description,
          :group_sector_name,
          :climbing_type,
          :height,
          :banner_bg_color,
          :polygon,
          :can_be_more_than_one_pitch,
          :three_d_height,
          :three_d_elevated,
          :linear_metre,
          :developed_metre,
          :category_name,
          :average_opening_time,
          three_d_path: %i[x y z],
          three_d_label_options: %i[x y z]
        )
      end

      def gym_sectors_bulk_params
        params.permit(
          gym_sectors: %i[
            id
            name
            order
            height
            linear_metre
            developed_metre
            category_name
            average_opening_time
          ]
        )
      end
    end
  end
end
