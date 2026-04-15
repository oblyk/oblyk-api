# frozen_string_literal: true

module Api
  module Embedded
    class GymsController < EmbeddedController
      before_action :set_gym

      def show
        spaces = @gym.gym_spaces
                     .includes(:gym_sectors, plan_attachment: :blob, three_d_picture_attachment: :blob)
                     .where(draft: false, archived_at: nil).map do |space|

          # Sectors informations
          sectors = space.gym_sectors.map do |gym_sector|
            {
              id: gym_sector.id,
              name: gym_sector.name,
              three_d_path: gym_sector.three_d_path,
              three_d_height: gym_sector.three_d_height,
              three_d_label_options: gym_sector.three_d_label_options,
              three_d_elevated: gym_sector.three_d_elevated,
              polygon: gym_sector.polygon,
              gym_space_id: gym_sector.gym_space_id
            }
          end

          # Spaces informations
          {
            id: space.id,
            name: space.name,
            svg_sectors: space.svg_sectors,
            sectors_color: space.sectors_color,
            text_contrast_color: Color.black_or_white_rgb(space.sectors_color || 'rgb(0,0,0)'),
            representation_type: space.representation_type,
            three_d_gltf_url: space.three_d_gltf_url,
            three_d_parameters: space.three_d_parameters,
            three_d_position: space.three_d_position,
            three_d_scale: space.three_d_scale,
            three_d_rotation: space.three_d_rotation,
            three_d_camera_position: space.three_d_camera_position,
            three_d_label_options: space.three_d_label_options,
            scheme_height: space.scheme_height,
            scheme_width: space.scheme_width,
            gym_sectors: sectors,
            attachments: {
              avatar: space.representation_type == '3d' ? space.attachment_object(space.three_d_picture) : space.attachment_object(space.plan),
              plan: space.attachment_object(space.plan),
              three_d_picture: space.attachment_object(space.three_d_picture)
            }
          }
        end

        # Assets informations
        assets = @gym.gym_three_d_elements.map do |element|
          {
            id: element.id,
            gym_space_id: element.gym_space_id,
            gym_three_d_asset: {
              id: element.gym_three_d_asset.id,
              name: element.gym_three_d_asset.name,
              slug_name: element.gym_three_d_asset.slug_name,
              description: element.gym_three_d_asset.description,
              three_d_gltf_url: element.gym_three_d_asset.three_d_gltf_url,
              three_d_parameters: element.gym_three_d_asset.three_d_parameters
            },
            three_d_position: element.three_d_position,
            three_d_rotation: element.three_d_rotation,
            three_d_scale: element.three_d_scale
          }
        end

        # Gym informations
        render json: {
          name: @gym.name,
          id: @gym.id,
          app_path: @gym.app_path,
          representation_type: @gym.representation_type,
          gym_spaces: spaces,
          assets: assets,
          attachments: {
            logo: @gym.attachment_object(@gym.logo)
          }
        }, status: :ok
      end

      def gym_routes
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

      def route
        gym_route = @gym.gym_routes.find_by id: params[:id]
        render json: gym_route.detail_to_json, status: :ok
      end

      private

      def set_gym
        @gym = Gym.find params[:id]

        render json: { error: 'Gym not found' }, status: :not_found unless @gym
      end
    end
  end
end
