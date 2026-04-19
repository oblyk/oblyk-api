# frozen_string_literal: true

module Api
  module Embedded
    class GymRoutesController < EmbeddedController
      before_action :set_gym

      def index
        gym_space_id = params.fetch(:gym_space_id, nil)
        gym_sector_id = params.fetch(:gym_sector_id, nil)
        page = params.fetch(:page, 1)
        sort = params.fetch(:sort, 'opened_at')

        gym_routes = @gym.gym_routes
                         .includes(:gym_sector, :gym_route_cover, :gym_openers, thumbnail_attachment: :blob, gym: :gym_levels, gym_sector: :gym_space)
                         .joins(gym_sector: :gym_space)
                         .mounted

        gym_routes = gym_routes.where(gym_sectors: { gym_space_id: gym_space_id }) if gym_space_id.present?
        gym_routes = gym_routes.where(gym_sectors: { id: gym_sector_id }) if gym_sector_id.present?
        gym_routes = gym_routes.reorder(opened_at: :desc) if sort == 'opened_at'
        gym_routes = gym_routes.reorder('gym_spaces.order, gym_spaces.name, gym_sectors.order, gym_sectors.name, gym_routes.id') if sort == 'sector'

        gym_routes = gym_routes.page(page)

        serializer = ::Embedded::GymRouteSerializer.new(
          gym_routes,
          {
            include: %i[gym_sector],
            params: {
              include_gym_route_cover: false,
              include_cover_metadata: false,
              include_attachments: {
                GymRoute: %i[thumbnail]
              }
            }
          }
        )

        render json: serializer.serializable_hash, status: :ok
      end

      def show
        gym_route = @gym.gym_routes.find_by id: params[:id]

        serializer = ::Embedded::GymRouteSerializer.new(
          gym_route,
          {
            include: [:gym_sector, 'gym_sector.gym_space'],
            params: {
              include_gym_route_cover: true,
              include_cover_metadata: true,
              include_attachments: {
                GymRoute: %i[thumbnail]
              }
            }
          }
        )

        render json: serializer.serializable_hash, status: :ok
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]

        render json: { error: 'Gym not found' }, status: :not_found unless @gym
      end
    end
  end
end
