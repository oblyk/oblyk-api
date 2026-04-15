# frozen_string_literal: true

module Api
  module Embedded
    class GymRoutesController < EmbeddedController
      before_action :set_gym

      def index
        gym_space_id = params.fetch(:gym_space_id, nil)
        page = params.fetch(:page, 1)
        sort = params.fetch(:sort, 'opened_at')

        gym_routes = @gym.gym_routes
                         .includes(:gym_sector, thumbnail_attachment: :blob, gym: :gym_levels)
                         .joins(gym_sector: :gym_space)
                         .mounted

        gym_routes = gym_routes.where(gym_sectors: { gym_space_id: gym_space_id }) if gym_space_id.present?
        gym_routes = gym_routes.reorder(opened_at: :desc) if sort == 'opened_at'
        gym_routes = gym_routes.reorder('gym_spaces.order, gym_spaces.name, gym_sectors.order, gym_sectors.name, gym_routes.id') if sort == 'sector'

        gym_routes = gym_routes.page(page)

        data = gym_routes.map do |gym_route|
          {
            id: gym_route.id,
            name: gym_route.name,
            opened_at: gym_route.opened_at,
            tag_colors: gym_route.tag_colors,
            hold_colors: gym_route.hold_colors,
            sub_level: gym_route.sub_level,
            sub_level_max: gym_route.sub_level_max,
            points_to_s: gym_route.points_to_s,
            grade_to_s: gym_route.grade_to_s,
            anchor_number: gym_route.anchor_number,
            likes_count: gym_route.likes_count,
            videos_count: gym_route.videos_count,
            all_comments_count: gym_route.all_comments_count,
            ascents_count: gym_route.ascents_count,
            gym_sector_id: gym_route.gym_sector_id,
            sections: gym_route.sections,
            gym_sector: {
              id: gym_route.gym_sector.id,
              name: gym_route.gym_sector.name,
              gym_space_id: gym_route.gym_sector.gym_space_id
            },
            attachments: {
              thumbnail: gym_route.attachment_object(gym_route.thumbnail)
            },
          }
        end

        render json: data, status: :ok
      end

      def show
        gym_route = @gym.gym_routes.find_by id: params[:id]
        render json: gym_route.detail_to_json, status: :ok
      end

      private

      def set_gym
        @gym = Gym.find params[:gym_id]

        render json: { error: 'Gym not found' }, status: :not_found unless @gym
      end
    end
  end
end
