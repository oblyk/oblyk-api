# frozen_string_literal: true

module Api
  module V1
    class ColorSystemsController < ApiController
      before_action :set_color_system, only: %i[show]
      before_action :set_gym, only: %i[index]
      before_action :protected_by_session, only: %i[create]

      def index
        count_select = if @gym
                         "(SELECT COUNT(*) FROM ascents INNER JOIN color_system_lines ON ascents.color_system_line_id = color_system_lines.id WHERE color_system_id = color_systems.id AND gym_id = #{@gym.id})"
                       else
                         '(SELECT COUNT(*) FROM ascents INNER JOIN color_system_lines ON ascents.color_system_line_id = color_system_lines.id WHERE color_system_id = color_systems.id)'
                       end
        color_systems = ColorSystem.select("#{count_select} AS count_usage, color_systems.*")
                                   .order(count_usage: :desc)
                                   .all
        systems = []
        color_systems.each do |system|
          summary_to_json = system.summary_to_json
          summary_to_json[:count_usage] = system[:count_usage]
          systems << summary_to_json
        end
        render json: systems, status: :ok
      end

      def show
        render json: @color_system.detail_to_json, status: :ok
      end

      def create
        color_params = params[:color_system][:colors]
        colors_mark = color_params.join
        return unless colors_mark

        color_system = ColorSystem.find_or_initialize_by colors_mark: colors_mark
        color_system.init_line_form_colors(color_params) if color_system.new_record?
        color_system.save

        render json: color_system.detail_to_json, status: :ok
      end

      private

      def set_color_system
        @color_system = ColorSystem.find params[:id]
      end

      def set_gym
        @gym = Gym.find_by id: params[:gym_id]
      end
    end
  end
end
