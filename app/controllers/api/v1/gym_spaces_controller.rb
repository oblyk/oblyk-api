# frozen_string_literal: true

module Api
  module V1
    class GymSpacesController < ApiController
      include Gymable
      skip_before_action :protected_by_session, only: %i[show index groups]
      skip_before_action :protected_by_gym_administrator, only: %i[show index groups]
      before_action :set_gym_space, except: %i[index create groups]
      before_action -> { can? GymRole::MANAGE_SPACE }, except: %i[index show groups]

      def index
        gym_spaces = @gym.gym_spaces
                         .joins('LEFT JOIN gym_space_groups ON gym_space_groups.id = gym_spaces.gym_space_group_id')
                         .reorder('gym_space_groups.order IS NULL ASC, gym_space_groups.order, gym_spaces.order')
        render json: gym_spaces.map { |gym_space| gym_space.summary_to_json(with_figures: true) }, status: :ok
      end

      def groups
        gym_spaces = @gym.gym_spaces
                         .joins('LEFT JOIN gym_space_groups ON gym_space_groups.id = gym_spaces.gym_space_group_id')
                         .reorder('gym_space_groups.order IS NULL ASC, gym_space_groups.order, gym_spaces.order')
        in_group = {}
        out_group = []
        gym_spaces.each do |gym_space|
          if gym_space.gym_space_group_id.present?
            in_group["group-#{gym_space.gym_space_group_id}"] ||= {
              id: gym_space.gym_space_group_id,
              name: gym_space.gym_space_group.name,
              order: gym_space.gym_space_group.order,
              gym_spaces: []
            }
            in_group["group-#{gym_space.gym_space_group_id}"][:gym_spaces] << gym_space.summary_to_json(with_figures: true)
          else
            out_group << gym_space.summary_to_json(with_figures: true)
          end
        end
        render json: {
          grouped_spaces: in_group.map(&:last),
          ungrouped_spaces: out_group
        }, status: :ok
      end

      def show
        render json: @gym_space.detail_to_json, status: :ok
      end

      def create
        @gym_space = GymSpace.new(gym_space_params)
        @gym_space.gym = @gym
        if @gym_space.save
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_space.update(gym_space_params)
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_space.destroy
          head :no_content
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def publish
        if @gym_space.publish!
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def unpublish
        if @gym_space.unpublish!
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def add_banner
        if @gym_space.update(banner_params)
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def add_plan
        if @gym_space.update(plan_params)
          @gym_space.set_plan_dimension!
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym_space
        @gym_space = GymSpace.find params[:id]
      end

      def gym_space_params
        params.require(:gym_space).permit(
          :name,
          :description,
          :order,
          :climbing_type,
          :sectors_color,
          :gym_grade_id,
          :gym_space_group_id,
          :anchor
        )
      end

      def banner_params
        params.require(:gym_space).permit(
          :banner
        )
      end

      def plan_params
        params.require(:gym_space).permit(
          :plan
        )
      end
    end
  end
end
