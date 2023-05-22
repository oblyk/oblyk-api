# frozen_string_literal: true

module Api
  module V1
    class GymsController < ApiController
      include GymRolesVerification

      before_action :protected_by_super_admin, only: %i[destroy]
      before_action :protected_by_session, only: %i[create update add_banner add_logo routes_count routes tree_structures]
      before_action :set_gym, only: %i[show versions ascent_scores update destroy add_banner add_logo routes_count routes tree_structures]
      before_action :protected_by_administrator, only: %i[update add_banner add_logo routes_count routes tree_structures]
      before_action :user_can_manage_gym, except: %i[index search geo_json show create gyms_around versions ascent_scores routes_count routes]

      def index
        gyms = params[:ids].present? ? Gym.where(id: params[:ids]) : Gym.all
        render json: gyms.map(&:summary_to_json), status: :ok
      end

      def search
        query = params[:query]
        gyms = Gym.search(query)
        render json: gyms.map(&:summary_to_json), status: :ok
      end

      def geo_json
        minimalistic = params.fetch(:minimalistic, false) != false
        render json: {
          type: 'FeatureCollection',
          crs: {
            type: 'name',
            properties: {
              name: 'urn'
            }
          },
          features: geo_json_features(minimalistic)
        }, status: :ok
      end

      def show
        render json: @gym.detail_to_json, status: :ok
      end

      def gyms_around
        distance = params.fetch(:distance, 20)
        gyms = Gym.geo_search(params[:latitude], params[:longitude], distance)
        render json: gyms.map(&:summary_to_json), status: :ok
      end

      def versions
        versions = @gym.versions
        render json: OblykVersion.index(versions), status: :ok
      end

      def ascent_scores
        start_date = params.fetch(:start_date, nil)
        end_date = params.fetch(:end_date, nil)
        start_date = Date.parse(start_date) if start_date
        end_date = Date.parse(end_date) if end_date

        ascents = AscentGymRoute.includes(:user)
                                .includes(gym_route: [:gym_grade_line, { gym_sector: :gym_grade }])
                                .where(gym: @gym)
                                .where.not(gym_route_id: nil)
        if start_date || end_date
          ascents = ascents.where(released_at: [start_date..end_date])
                           .where('created_at >= ?', start_date.beginning_of_day)
                           .where('created_at <= ?', (end_date + 1.day).end_of_day)
        end

        scores = {}
        ascents.find_each do |ascent|
          user_key = "user-#{ascent.user_id}"
          scores[user_key] ||= {
            points: 0,
            rank: nil,
            user: ascent.user.summary_to_json
          }
          scores[user_key][:points] += ascent.gym_route.calculated_point || 0
        end
        scores = scores.map(&:last)
        scores.sort_by! { |score| -score[:points] }
        ranked_score = []
        scores.each_with_index do |score, index|
          score[:rank] = index + 1
          ranked_score << score
        end
        render json: ranked_score, status: :ok
      end

      def create
        @gym = Gym.new(gym_params)
        @gym.user = @current_user
        if @gym.save
          render json: @gym.detail_to_json, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym.update(gym_params)
          render json: @gym.detail_to_json, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def add_banner
        if @gym.update(banner_params)
          render json: @gym.detail_to_json, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def add_logo
        if @gym.update(logo_params)
          render json: @gym.detail_to_json, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym.destroy
          render json: {}, status: :ok
        else
          render json: { error: @gym.errors }, status: :unprocessable_entity
        end
      end

      def routes_count
        render json: @gym.gym_routes.mounted.count, status: :ok
      end

      def routes
        gym_routes = if params.fetch(:dismounted, 'false') == 'true'
                       @gym.gym_routes.dismounted
                     else
                       @gym.gym_routes.mounted
                     end
        render json: gym_routes.map(&:summary_to_json), status: :ok
      end

      def tree_structures
        tree = {
          gym: {
            name: @gym.name,
            slug_name: @gym.name,
            id: @gym.id,
            gym_spaces: [],
            gym_space_groups: []
          }
        }
        @gym.gym_space_groups.each do |gym_space_group|
          space_group = {
            id: gym_space_group.id,
            name: gym_space_group.name,
            order: gym_space_group.order,
            gym: {
              id: gym_space_group.gym_id,
              slug_name: gym_space_group.gym.id
            },
            gym_spaces: []
          }
          gym_space_group.gym_spaces.each do |gym_space|
            sectors = []
            gym_space.gym_sectors.each do |gym_sector|
              sectors << gym_sector.summary_to_json
            end
            space = gym_space.summary_to_json.merge({ gym_sectors: sectors })
            space_group[:gym_spaces] << space
          end
          tree[:gym][:gym_space_groups] << space_group
        end
        @gym.gym_spaces.where(gym_space_group_id: nil).each do |gym_space|
          sectors = []
          gym_space.gym_sectors.each do |gym_sector|
            sectors << gym_sector.summary_to_json
          end
          space = gym_space.summary_to_json.merge({ gym_sectors: sectors })
          tree[:gym][:gym_spaces] << space
        end

        render json: tree, status: :ok
      end

      private

      def geo_json_features(minimalistic)
        features = []
        gyms = minimalistic ? Gym.all : Gym.includes(banner_attachment: :blob).all
        gyms.each do |gym|
          features << gym.to_geo_json(minimalistic: minimalistic)
        end
        features
      end

      def set_gym
        @gym = Gym.find params[:id]
      end

      def protected_by_administrator
        return if @current_user.super_admin

        return unless @gym.administered?

        not_authorized if @gym.gym_administrators.where(user_id: @current_user.id).count.zero?
      end

      def gym_params
        params.require(:gym).permit(
          :name,
          :description,
          :address,
          :postal_code,
          :code_country,
          :country,
          :city,
          :big_city,
          :region,
          :email,
          :phone_number,
          :web_site,
          :bouldering,
          :sport_climbing,
          :pan,
          :fun_climbing,
          :training_space,
          :latitude,
          :longitude
        )
      end

      def banner_params
        params.require(:gym).permit(
          :banner
        )
      end

      def logo_params
        params.require(:gym).permit(
          :logo
        )
      end

      def user_can_manage_gym
        can? GymRole::MANAGE_GYM if @gym.administered?
      end
    end
  end
end
