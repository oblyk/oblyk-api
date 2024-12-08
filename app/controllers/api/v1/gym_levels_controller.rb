# frozen_string_literal: true

module Api
  module V1
    class GymLevelsController < ApiController
      include Gymable
      before_action -> { can? GymRole::MANAGE_SPACE }, except: %i[index update_all]

      def index
        gym_levels = @gym.gym_levels

        average_by_level_for_sector_id = params.fetch(:average_for_sector_id, nil)
        if average_by_level_for_sector_id
          json_levels = []
          level_by_index = GymRoute.select('ROUND(AVG(min_grade_value)) AS average_grade, level_index, climbing_type')
                                   .where(gym_sector_id: average_by_level_for_sector_id)
                                   .group(:climbing_type, :level_index)
          by_climbs = level_by_index.group_by(&:climbing_type)
          gym_levels.each do |gym_level|
            json_level = gym_level.summary_to_json
            levels_for_climb = by_climbs[gym_level.climbing_type]
            if levels_for_climb
              json_level[:levels]&.each_with_index do |level, index|
                levels_for_climb.each do |level_for_climb|
                  json_level[:levels][index]['average_grade'] = level_for_climb[:average_grade] if level_for_climb[:level_index] == level['order']
                end
              end
            end
            json_levels << json_level
          end
          render json: json_levels, status: :ok
        else
          render json: gym_levels.map(&:summary_to_json), status: :ok
        end
      end

      def update_all
        %i[sport_climbing bouldering pan].each do |climbing_type|
          level = GymLevel.find_by(gym_id: @gym.id, climbing_type: climbing_type)
          level.update gym_levels_params[climbing_type]
        end
      end

      private

      def set_gym_level
        @gym_level = GymLevel.find params[:id]
      end

      def gym_levels_params
        params.require(:gym_levels).permit(
          sport_climbing: [
            :grade_system,
            :level_representation,
            { levels: %i[order color default_grade default_point] }
          ],
          bouldering: [
            :grade_system,
            :level_representation,
            { levels: %i[order color default_grade default_point] }
          ],
          pan: [
            :grade_system,
            :level_representation,
            { levels: %i[order color default_grade default_point] }
          ]
        )
      end
    end
  end
end
