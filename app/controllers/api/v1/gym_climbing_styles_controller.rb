# frozen_string_literal: true

module Api
  module V1
    class GymClimbingStylesController < ApiController
      include Gymable
      before_action -> { can? GymRole::MANAGE_SPACE }, except: %i[index]

      def index
        styles = {}
        gym_climbing_styles = @gym.gym_climbing_styles.where(deactivated_at: nil)
        gym_climbing_styles.each do |gym_climbing_style|
          styles[gym_climbing_style.climbing_type] ||= []
          styles[gym_climbing_style.climbing_type] << gym_climbing_style.summary_to_json
        end
        render json: styles, status: :ok
      end

      def create
        gym_climbing_style = @gym.gym_climbing_styles.find_or_initialize_by(
          style: gym_climbing_style_params[:style],
          climbing_type: gym_climbing_style_params[:climbing_type]
        )
        gym_climbing_style.color = gym_climbing_style_params[:color]
        gym_climbing_style.deactivated_at = nil
        if gym_climbing_style.save
          render json: gym_climbing_style.detail_to_json, status: :ok
        else
          render json: { error: gym_climbing_style.errors }, status: :unprocessable_entity
        end
      end

      def deactivate
        gym_climbing_style = @gym.gym_climbing_styles.find_by(
          style: gym_climbing_style_params[:style],
          climbing_type: gym_climbing_style_params[:climbing_type]
        )
        if gym_climbing_style.blank? || gym_climbing_style.deactivate!
          head :no_content
        else
          render json: { error: gym_climbing_style.errors }, status: :unprocessable_entity
        end
      end

      private

      def gym_climbing_style_params
        params.require(:gym_climbing_style).permit(
          :color,
          :style,
          :climbing_type
        )
      end
    end
  end
end
