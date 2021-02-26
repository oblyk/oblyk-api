# frozen_string_literal: true

module Api
  module V1
    class CurrentUsersController < ApiController
      before_action :protected_by_session
      before_action :set_user

      def show; end

      def favorites
        @subscribes = @user.subscribes.where.not(followable_type: %w[GuideBookPaper User]).order(views: :desc)
        render 'api/v1/current_users/subscribes'
      end

      def subscribes
        @subscribes = @user.subscribes.where(followable_type: 'User').order(updated_at: :desc)
        render 'api/v1/current_users/subscribes'
      end

      def followers
        @users = []
        followers = @user.follows.order(created_at: :desc)
        followers.each do |follower|
          @users << follower.user
        end
        render 'api/v1/users/index'
      end

      def ascents_crag_routes
        render json: @user.ascent_crag_routes_to_a, status: :ok
      end

      def ascended_crag_routes
        crag_route_ids = @user.ascent_crag_routes.made.pluck(:crag_route_id)
        @crag_routes = case params[:order]
                       when 'crags'
                         CragRoute.where(id: crag_route_ids).joins(:crag).order('crags.name')
                       when 'released_at'
                         CragRoute.where(id: crag_route_ids).order(released_at: :desc)
                       else
                         CragRoute.where(id: crag_route_ids).order(max_grade_value: :desc)
                       end
        render 'api/v1/crag_routes/index'
      end

      def library
        @subscribes = @user.subscribes.where(followable_type: %w[GuideBookPaper]).order(views: :desc)
        render :subscribes
      end

      def projects
        project_crag_route_ids = @user.ascent_crag_routes.project.pluck(:crag_route_id)
        crag_route_ids = @user.ascent_crag_routes.made.pluck(:crag_route_id)
        @crag_routes = CragRoute.where(id: project_crag_route_ids).where.not(id: crag_route_ids).joins(:crag).order('crags.name')
        render 'api/v1/crag_routes/index'
      end

      def tick_lists
        @crag_routes = @user.ticked_crag_routes.joins(:crag).order('crags.name')
        render 'api/v1/crag_routes/index'
      end

      def update
        if @user.update(user_params)
          render :show
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      def banner
        if @user.update(banner_params)
          render :show
        else
          render json: { error: @user.errors }, status: :unprocessable_entity
        end
      end

      def avatar
        if @user.update(avatar_params)
          render :show
        else
          render json: { error: @user.errors }, status: :unprocessable_entity
        end
      end

      def ascended_crags_geo_json
        features = []

        @user.ascended_crags.distinct.each do |crag|
          features << crag.to_geo_json
        end

        render json: {
          type: 'FeatureCollection',
          crs: {
            type: 'name',
            properties: {
              name: 'urn'
            }
          },
          features: features
        }, status: :ok
      end

      private

      def set_user
        @user = @current_user
      end

      def user_params
        params.require(:user).permit(
          :first_name,
          :last_name,
          :date_of_birth,
          :genre,
          :description,
          :latitude,
          :longitude,
          :localization,
          :partner_search,
          :bouldering,
          :sport_climbing,
          :multi_pitch,
          :trad_climbing,
          :aid_climbing,
          :deep_water,
          :via_ferrata,
          :pan,
          :grade_max,
          :grade_min,
          :language,
          :public_profile,
          :public_outdoor_ascents,
          :public_indoor_ascents,
          :partner_latitude,
          :partner_longitude
        )
      end

      def banner_params
        params.require(:user).permit(
          :banner
        )
      end

      def avatar_params
        params.require(:user).permit(
          :avatar
        )
      end
    end
  end
end
