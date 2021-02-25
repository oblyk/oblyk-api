# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      before_action :set_user
      before_action :protected_private_profile

      def show; end

      def contribution
        render json: {
          crags_count: Crag.where(user: @user).count,
          gyms_count: Gym.where(user: @user).count,
          routes_count: CragRoute.where(user: @user).count,
          photos_count: Photo.where(user: @user).count,
          videos_count: Video.where(user: @user).count,
          guides_count: GuideBookPaper.where(user: @user).count + GuideBookPdf.where(user: @user).count + GuideBookWeb.where(user: @user).count,
          comments_count: Comment.where(user: @user).count + Ascent.where.not(comment: nil).where(private_comment: false).where(user: @user).count
        }, status: :ok
      end

      def partner_user_geo_json
        render json: {
          type: 'FeatureCollection',
          crs: {
            type: 'name',
            properties: {
              name: 'urn'
            }
          },
          features: [
            @user.to_partner_geo_json
          ]
        }, status: :ok
      end

      private

      def protected_private_profile
        return if @user.public_profile
        return if login?

        render json: {}, status: :unauthorized
      end

      def set_user
        @user = User.find_by uuid: params[:id]
      end
    end
  end
end
