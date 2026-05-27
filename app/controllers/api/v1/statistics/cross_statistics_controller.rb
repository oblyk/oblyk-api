# frozen_string_literal: true

module Api
  module V1
    module Statistics
      class CrossStatisticsController < ApiController
        include Gymable

        def index
          available_params = %i[sector anchor like style opener number_of_ascension grade level comment]
          by = available_params.include?(params[:by].to_sym) ? params[:by] : :sector
          number_of = available_params.include?(params[:number_of].to_sym) ? params[:number_of] : :grade
          gym_space_ids = params.fetch(:gym_space_ids, nil)&.to_a&.map(&:to_i)
          opened_at = params.fetch(:opened_at, Date.current)
          opened_at = Date.parse(opened_at) if opened_at.is_a?(String)
          results = []

          field_select = {
            anchor: 'CONCAT(gym_spaces.name, " / ", gym_routes.anchor_number)',
            sector: 'CONCAT(gym_spaces.name, " / ", gym_sectors.name)',
            grade: 'gym_routes.min_grade_value',
            number_of_ascension: 'IF(gym_routes.ascents_count = 0, NULL, gym_routes.ascents_count)',
            like: 'IF(gym_routes.likes_count = 0, NULL, gym_routes.likes_count)',
            opener: 'gym_openers.name',
            style: 'gym_route_styles.style',
            level: 'CONCAT(LPAD(gym_routes.level_index, 2, "0"),"-",gym_routes.level_color)',
            comment: 'gym_routes.all_comments_count'
          }

          column_headers = GymRoute.joins(gym_sector: :gym_space)
          column_headers = column_headers.joins(gym_route_openers: :gym_opener) if number_of == 'opener'
          column_headers = column_headers.joins("INNER JOIN JSON_TABLE(gym_routes.sections, '$[*].styles[*]' COLUMNS (style VARCHAR(255) PATH '$')) AS gym_route_styles") if number_of == 'style'
          column_headers = column_headers.joins(gym_sector: :gym_space)
                                         .select("DISTINCT #{field_select[number_of.to_sym]} AS distinct_number_of")
                                         .where(
                                           gym_spaces: { gym_id: @gym.id, archived_at: nil, deleted_at: nil },
                                           dismounted_at: nil
                                         )
                                         .order('distinct_number_of')
                                         .map(&:distinct_number_of)

          routes = GymRoute.joins(gym_sector: :gym_space)
          routes = routes.joins(gym_route_openers: :gym_opener) if by == 'opener' || number_of == 'opener'
          routes = routes.joins("INNER JOIN JSON_TABLE(gym_routes.sections, '$[*].styles[*]' COLUMNS (style VARCHAR(255) PATH '$')) AS gym_route_styles") if by == 'style' || number_of == 'style'

          routes = routes.select("COUNT(*) AS count, #{field_select[by.to_sym]} AS by_field, #{field_select[number_of.to_sym]} AS number_of")
          routes = routes.where(gym_spaces: { id: gym_space_ids }) if gym_space_ids
          routes = routes.where(gym_spaces: { gym_id: @gym.id, archived_at: nil, deleted_at: nil })
                         .where('gym_routes.dismounted_at IS NULL OR gym_routes.dismounted_at > ?', opened_at)
                         .group('by_field, number_of')
                         .order('by_field, number_of')

          routes = routes.group_by(&:by_field)

          routes.each do |route|
            data = {}
            column_headers.each do |col|
              data[col] = nil
            end
            route[1].each do |route_data|
              data[route_data['number_of']] = route_data['count']
            end
            results << {
              value: route[0],
              data: data.map(&:second)
            }
          end

          render json: {
            params: { by: by, number_of: number_of },
            column_headers: column_headers,
            results: results
          }, status: :ok
        end
      end
    end
  end
end
